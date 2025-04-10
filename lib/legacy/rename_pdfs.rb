#!/usr/bin/env ruby
# frozen_string_literal: true

# ------------------------------------------------------------------------------
# rename_pdfs.rb
#
# Intelligent renaming of PDF documents based on their content using LangChain.rb
# Also provides detailed document analysis.
#
# Requirements:
#   - Ruby 3+
#   - Ollama running locally, or OpenAI API key
#   - Install: `gem install langchainrb`
#   - System package: `pdftoppm` (from poppler-utils) for PDF to image conversion
#   - System package: `libvips` for image support
#
# Install dependencies:
#   - macOS: `brew install libvips poppler`
#   - Ubuntu: `sudo apt install libvips-tools poppler-utils`
#
# Usage:
#   ruby rename_pdfs.rb /path/to/pdfs
#   ruby rename_pdfs.rb /path/to/pdfs --force  # Actually rename files
#   ruby rename_pdfs.rb /path/to/pdfs --no-debug  # Hide analysis details
#   ruby rename_pdfs.rb /path/to/pdfs --provider openai  # Use OpenAI instead of Ollama
# ------------------------------------------------------------------------------

require "bundler/inline"

gemfile(false) do
  gem "langchainrb"
  gem "ruby-vips"
  gem "pdf-reader"
  gem "base64"
  gem "json"
  gem "activesupport"
  gem "debug"
  gem "faraday"
  gem "ruby-openai"
end

require "langchain"
require "vips"
require "base64"
require "fileutils"
require "optparse"
require "pdf/reader"
require "json"
require "date"
require "active_support/core_ext/string"
require "faraday"
require "debug"

class LlmHandlerBase
  def analyze_document(image)
    raise NotImplementedError
  end

  protected

  def base64_encode(image)
    Base64.strict_encode64(File.binread(image))
  end

  def analysis_prompt
    <<~TEXT
      Analyze this document image and return ONLY a JSON object with these fields:
      {
        "sender_name": "Company or person who sent the document",
        "receiver_name": "Company or person receiving the document",
        "main_date": "Main document date in YYYY-MM-DD format",
        "category": "Document category in German (e.g. Rechnung, Brief, Vertrag, Mahnung, Beleg, Angebot, misc)"
      }
      Respond only with valid JSON. Do not write an introduction or summary.
      Do not include any additional information or comments. Do just return the JSON object without markdown other wrappers
    TEXT
  end
end

class Llama3Handler < LlmHandlerBase
  def initialize
    @llm = Langchain::LLM::Ollama.new(
      default_options: {
        chat_model: "llama3.2-vision:11b",
        temperature: 0.1,
        response_format: "json"
      }
    )
  end

  def analyze_document(image)
    b64 = base64_encode(image)
    messages = [{
      role: "user",
      content: analysis_prompt,
      images: [b64],
      format: "json"
    }]

    response = @llm.chat(messages: messages)
    JSON.parse(response.raw_response.dig('message', 'content'))
  end
end


class Gemma3Handler < LlmHandlerBase
  def initialize
    @llm = Langchain::LLM::Ollama.new(
      default_options: {
        chat_model: "gemma3:12b",
        temperature: 0.1,    # Lower temperature for more consistent responses
        num_predict: 512,    # Reasonable limit for JSON response
        system: "You are a document analysis expert that always responds in valid JSON format."
      }
    )
  end

  def analyze_document(image)
    b64 = base64_encode(image)
    messages = [{
      role: "user",
      content: gemma_prompt,
      images: [b64],
      format: "json"
    }]

    response = @llm.chat(messages: messages)

    # Clean the response to handle potential markdown or text wrapping
    content = response.raw_response.dig('message', 'content')
    json_str = extract_json(content)

    parse_json_safely(json_str)
  end

  private

  def gemma_prompt
    <<~PROMPT
      Look at this document image and extract these specific details:

      1. Sender: Who sent this document? (Look at letterhead or signature)
      2. Receiver: Who is this document for? (Look at recipient details)
      3. Date: What is the main document date?
      4. Type: What kind of document is this?

      Return only a JSON object with this exact structure:
      {
        "sender_name": "<extracted sender>",
        "receiver_name": "<extracted receiver>",
        "main_date": "<date in YYYY-MM-DD>",
        "category": "<one of: Rechnung, Brief, Vertrag, Mahnung, Beleg, Angebot, misc>"
      }

      Important: Respond with ONLY the JSON object. No other text or explanation.
    PROMPT
  end

  def extract_json(content)
    # Extract JSON if wrapped in markdown or other text
    if content.include?('{') && content.include?('}')
      content[/\{.*\}/m] || content
    else
      content
    end
  end

  def parse_json_safely(str)
    JSON.parse(str)
  rescue JSON::ParserError
    # Fallback with basic structure if parsing fails
    {
      "sender_name" => "Unknown",
      "receiver_name" => "Unknown",
      "main_date" => "",
      "category" => "misc"
    }
  end
end

class OpenAiHandler < LlmHandlerBase
  def initialize
    @llm = Langchain::LLM::OpenAI.new(
      api_key: ENV["OPENAI_API_KEY"],
      default_options: { model: 'gpt-4', temperature: 0.1 }
    )
  end

  def analyze_document(image)
    b64 = base64_encode(image)
    messages = [{
      role: "user",
      content: [
        { type: "text", text: analysis_prompt },
        { type: "image_url", image_url: { url: "data:image/png;base64,#{b64}" } }
      ]
    }]

    response = @llm.chat(messages: messages)
    JSON.parse(response.raw_response.dig('choices').first.dig('message', 'content'))
  end
end

class Phi4Handler < LlmHandlerBase
  def initialize
    @llm = Langchain::LLM::Ollama.new(
      default_options: {
        chat_model: "phi4:latest",
        temperature: 0.1,    # Lower temperature for more consistent, factual responses
        num_predict: 512,    # Limit token generation but ensure enough for JSON
        top_k: 10,          # Narrow down token selection for more precise outputs
        top_p: 0.1          # Further increase precision
      }
    )
  end

  def analyze_document(image)
    b64 = base64_encode(image)
    messages = [{
      role: "user",
      content: analysis_prompt,
      images: [b64],
      format: "json"
    }]

    response = @llm.chat(messages: messages)

    # Phi-2 might include additional text, so we need to extract just the JSON part
    content = response.raw_response.dig('message', 'content')
    json_str = extract_json_from_text(content)

    begin
      JSON.parse(json_str)
    rescue JSON::ParserError
      # Fallback with basic structure if JSON parsing fails
      {
        "sender_name" => "Unknown",
        "receiver_name" => "Unknown",
        "main_date" => "",
        "category" => "misc"
      }
    end
  end

  private

  def extract_json_from_text(text)
    # Extract JSON-like content between curly braces
    if match = text.match(/\{.*\}/m)
      match[0]
    else
      "{}" # Return empty JSON if no match found
    end
  end

  protected

  def analysis_prompt
    <<~PROMPT
      Task: Extract key information from this document image into a JSON format.

      Required format:
      {
        "sender_name": "who sent the document",
        "receiver_name": "who received the document",
        "main_date": "date in YYYY-MM-DD format",
        "category": "document type in German (Rechnung/Brief/Vertrag/Mahnung/Beleg/Angebot/misc)"
      }

      Rules:
      1. Only look at visible text in the image
      2. Use "Unknown" if information isn't clear
      3. Return only the JSON object
      4. Make sure the JSON is properly formatted
      5. For category, only use the allowed German terms listed above

      Analyze the image and respond with only the JSON object.
    PROMPT
  end
end

class Qwen2Handler < LlmHandlerBase
  def initialize
    @llm = Langchain::LLM::Ollama.new(
      default_options: {
        chat_model: "siasi/qwen2-vl-7b-instruct:latest",
        temperature: 0.1,    # Lower temperature for more consistent, factual responses
        num_predict: 512,    # Reasonable limit for JSON response
        top_p: 0.9,         # Slightly reduced for more focused responses
        format: "json"      # Request JSON output explicitly
      }
    )
  end

  def analyze_document(image)
    b64 = base64_encode(image)
    messages = [{
      role: "user",
      content: analysis_prompt,
      images: [b64]
    }]

    response = @llm.chat(messages: messages)

    # Handle potential JSON parsing issues
    begin
      JSON.parse(response.raw_response.dig('message', 'content'))
    rescue JSON::ParserError => e
      # Clean up response to extract JSON
      content = response.raw_response.dig('message', 'content')
      json_str = content.match(/\{.*\}/m)&.to_s || '{}'
      JSON.parse(json_str)
    rescue => e
      # Fallback with basic structure
      {
        "sender_name" => "Unknown",
        "receiver_name" => "Unknown",
        "main_date" => "",
        "category" => "misc"
      }
    end
  end

  protected

  def analysis_prompt
    <<~PROMPT
      You are a document analysis assistant. I will show you a document image.
      Extract the following information and return it ONLY as a JSON object:

      1. Sender: Look for the letterhead, company logo, or sender details at the top
      2. Receiver: Find the recipient's details in the address block
      3. Date: Locate the primary document date (usually near the top)
      4. Category: Determine if this is a Rechnung, Brief, Vertrag, Mahnung, Beleg, Angebot, or misc

      Important rules:
      - Return ONLY a JSON object without any other text
      - Use exactly these keys: "sender_name", "receiver_name", "main_date" (YYYY-MM-DD format), "category"
      - For dates, only return the main document date in YYYY-MM-DD format
      - For category, only use one of these German terms: Rechnung, Brief, Vertrag, Mahnung, Beleg, Angebot, misc
      - If you're unsure about any field, use "Unknown" for names, empty string for date, and "misc" for category

      Example format:
      {"sender_name": "Company GmbH", "receiver_name": "Client AG", "main_date": "2024-02-20", "category": "Rechnung"}
    PROMPT
  end
end


class BakllavaHandler < LlmHandlerBase
  def initialize
    @llm = Langchain::LLM::Ollama.new(
      default_options: {
        chat_model: "bakllava",
        temperature: 0.1,  # Lower temperature for more consistent responses
        num_predict: 256   # Limit token generation for faster responses
      }
    )
  end

  def analyze_document(image)
    b64 = base64_encode(image)
    messages = [{
      role: "user",
      content: analysis_prompt,
      images: [b64],
      format: "json"
    }]

    response = @llm.chat(messages: messages)
    pp response
    JSON.parse(response.raw_response.dig('message', 'content'))
  rescue JSON::ParserError => e
    # Fallback with basic structure if JSON parsing fails
    {
      "sender_name": "Unknown",
      "receiver_name": "Unknown",
      "main_date": "",
      "category": "misc"
    }
  end

  protected

  def analysis_prompt
    <<~PROMPT
      You are a document analysis expert. Look at this document carefully and extract key information.
      Focus specifically on identifying:
      1. The company or person who sent the document (look for letterhead, signatures, or sender details)
      2. The recipient (look for addressing information)
      3. The primary date (focus on the most prominent date, usually at the top)
      4. The document type (Rechnung, Brief, Vertrag, Mahnung, Beleg, Angebot, or misc)

      Format your response as a JSON object with these exact keys:
      {
        "sender_name": "extracted sender",
        "receiver_name": "extracted receiver",
        "main_date": "YYYY-MM-DD",
        "category": "document category in German"
      }

      Respond only with the JSON object. No other text.
    PROMPT
  end
end

class PdfHandler
  def initialize(dpi: 200) = @dpi = dpi

  def to_image(pdf)
    output = "#{pdf.sub(/\.pdf$/i, '')}-1.png"
    cmd = "pdftoppm -f 1 -l 1 -r #{@dpi} -png -scale-to 1200 \"#{pdf}\" \"#{pdf.sub(/\.pdf$/i, '')}\""

    system(cmd)
    output
  end

  def generate_filename(analysis)
    date = analysis["main_date"].to_s
    date_prefix = Date.parse(date).strftime("%Y%m%d-") rescue ""

    sender = analysis["sender_name"].to_s.parameterize[0..30]
    category = analysis["category"].to_s.parameterize

    "#{date_prefix}#{sender}-#{category}.pdf"
  end

  def rename(old_path, new_name, force: false)
    new_path = File.join(File.dirname(old_path), new_name)
    message = if force
      FileUtils.mv(old_path, new_path)
      "Renamed to"
    else
      "Suggestion"
    end
    puts "#{message}: #{File.basename(old_path)} -> #{new_name}"
  end

  def cleanup(path)
    File.delete(path) if File.exist?(path)
  end
end

class PdfRenamer
  def initialize(directory:, force: false, provider: :open_ai, dpi: 200, debug: true)
    @dir = directory
    @force = force
    @dpi = dpi
    @debug = debug
    @llm_handler = llm_handler_for(provider)
    @pdf_handler = PdfHandler.new(dpi: dpi)
  end

  def process = pdf_files.shuffle[0,3].each { |pdf| process_file(pdf) }

  private

  def process_file(pdf)
    puts pdf
    img = @pdf_handler.to_image(pdf)
    return unless img && File.exist?(img)

    analysis = @llm_handler.analyze_document(img)
    output_debug(analysis) if @debug

    new_name = @pdf_handler.generate_filename(analysis)
    @pdf_handler.rename(pdf, new_name, force: @force)
    @pdf_handler.cleanup(img)
  end

  def pdf_files = Dir.glob(File.join(@dir, "*.pdf"))
  def llm_handler_for(provider) = Object.const_get("#{provider.to_s.camelize}Handler").new

  def output_debug(analysis)
    puts "\nDocument Analysis:"
    puts JSON.pretty_generate(analysis)
  end
end

# Script execution
options = { force: false, debug: true, provider: :open_ai }
OptionParser.new do |opts|
  opts.banner = "Usage: ruby rename_pdfs.rb [DIRECTORY] [options]"
  opts.on("-f", "--force", "Actually rename files") { options[:force] = true }
  opts.on("--[no-]debug", "Show/hide analysis details") { |v| options[:debug] = v }
  opts.on("-p", "--provider PROVIDER", "LLM provider (llama2/open_ai)") { |v| options[:provider] = v }
end.parse!

dir = ARGV[0] || "."
unless Dir.exist?(dir)
  puts "Directory not found: #{dir}"
  exit 1
end

Langchain.logger.level = Logger::FATAL

PdfRenamer.new(
  directory: dir,
  force: options[:force],
  debug: options[:debug],
  provider: options[:provider]
).process
