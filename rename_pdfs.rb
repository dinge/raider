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


class PdfRenamer
  MODELS = {
    llama2: -> { Langchain::LLM::Ollama.new(default_options: { chat_model: "llama3.2-vision:11b" }) },
    openai: -> { Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"], default_options: { model: 'gpt-4', temperature: 0.1 }) }
  }

  def initialize(directory:, force: false, provider: :openai, dpi: 200, debug: true)
    @dir = directory
    @force = force
    @dpi = dpi
    @debug = debug
    @llm = MODELS.fetch(provider.to_sym).call
  end

  def run
    pdf_files[0, 1].each { |pdf| process(pdf) }
  end

  private

  def pdf_files
    Dir.glob(File.join(@dir, "*.pdf"))
  end

  def process(pdf)
    puts pdf
    img = to_image(pdf)
    return unless img && File.exist?(img)

    response = analyze_document(img)
    puts JSON.pretty_generate(response.raw_response)

    analysis = if (choices = response.raw_response.dig('choices'))
      JSON.parse(choices.first.dig('message', 'content'))
    else
      JSON.parse(response.raw_response.dig('message', 'content'))
    end

    output_debug(analysis) if @debug
    new_name = generate_filename(analysis)
    rename(pdf, new_name)
    cleanup(img)
  rescue => e
    puts "Error processing #{pdf}: #{e.message}"
  end

  def to_image(pdf)
    output = "#{pdf.sub(/\.pdf$/i, '')}-1.png"
    cmd = "pdftoppm -f 1 -l 1 -r #{@dpi} -png -scale-to 1200 \"#{pdf}\" \"#{pdf.sub(/\.pdf$/i, '')}\""

    if system(cmd)
      output
    else
      puts "Failed to convert PDF to image: #{pdf}"
      nil
    end
  end

  def analyze_document(image)
    b64 = Base64.strict_encode64(File.binread(image))
    messages = [{
      role: "user",
      content: [
        { type: "text", text: analysis_prompt },
        { type: "image_url", image_url: { url: "data:image/png;base64,#{b64}" } }
      ]
    }]

    @llm.chat(messages: messages)
  end

  # def analyze_document(image)
  #   b64 = Base64.strict_encode64(File.binread(image))
  #   messages = [{
  #     role: "user",
  #     content:  analysis_prompt,
  #     images: [b64]
  #   }]

  #   @llm.chat(messages: messages)
  # end

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

  def generate_filename(analysis)
    date = analysis["main_date"].to_s
    date_prefix = Date.parse(date).strftime("%Y%m%d-") rescue ""

    sender = analysis["sender_name"].to_s.parameterize[0..30]
    category = analysis["category"].to_s.parameterize

    "#{date_prefix}#{sender}-#{category}.pdf"
  end

  def output_debug(analysis)
    puts "\nDocument Analysis:"
    puts JSON.pretty_generate(analysis)
  end

  def rename(old_path, new_name)
    new_path = File.join(File.dirname(old_path), new_name)
    if @force
      FileUtils.mv(old_path, new_path)
      puts "Renamed to: #{File.basename(old_path)} -> #{new_name}"
    else
      puts "Suggestion: #{File.basename(old_path)} -> #{new_name}"
    end
  end

  def cleanup(path)
    File.delete(path) if File.exist?(path)
  end
end

options = { force: false, debug: false, provider: :openai }
OptionParser.new do |opts|
  opts.banner = "Usage: ruby rename_pdfs.rb [DIRECTORY] [options]"
  opts.on("-f", "--force", "Actually rename files") { options[:force] = true }
  opts.on("--[no-]debug", "Show/hide analysis details") { |v| options[:debug] = v }
  opts.on("-p", "--provider PROVIDER", "LLM provider (llama2/openai)") { |v| options[:provider] = v }
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
).run
