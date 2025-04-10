#!/usr/bin/env ruby
# frozen_string_literal: true

# ------------------------------------------------------------------------------
# rename_pdfs.rb
#
# Intelligent renaming of PDF documents based on their content using Ollama.
# Also provides detailed document analysis.
#
# Requirements:
#   - Ruby 3+
#   - Ollama running locally with the model: bakllava:7b
#     Install with: `ollama pull bakllava:7b`
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
# ------------------------------------------------------------------------------

require "bundler/inline"

gemfile(false) do
  # source "https://rubygems.org"
  gem "ollama-rb", require: "ollama"
  gem "ruby-vips"
  gem "pdf-reader"
  gem "base64"
  gem "json"
  gem "activesupport"
  gem "debug"
end

require "vips"
require "ollama"
require "base64"
require "fileutils"
require "optparse"
require "pdf/reader"
require "json"
require "date"
require "active_support/core_ext/string"
require "debug"

class PdfRenamer
  def initialize(directory:, force: false, model: "llama3.2-vision:11b", dpi: 200, debug: true)
    @dir = directory
    @force = force
    @model = model
    @dpi = dpi
    @debug = debug
    @client = Ollama::Client.new
  end

  def run
    pdf_files.each { |pdf| process(pdf) }
  end

  private

  def pdf_files
    Dir.glob(File.join(@dir, "*.pdf"))
  end

  def process(pdf)
    puts pdf
    img = to_image(pdf)
    return unless img && File.exist?(img)

    analysis = analyze_document(img)
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
    res = @client.chat.create(
      model: @model,
      messages: [analysis_prompt(b64)]
    )

    begin
      JSON.parse(res.result.dig('message', 'content'))
    rescue JSON::ParserError => e
      puts "Warning: Could not parse AI response: #{e.message}"
      {}
    end
  end

  def analysis_prompt(img_b64)
    {
      role: "user",
      content: <<~TEXT,
        Analyze this document and return ONLY a JSON object with these fields:
        {
          "sender_name": "Company or person who sent the document",
          "receiver_name": "Company or person receiving the document",
          "main_date": "Main document date in YYYY-MM-DD format",
          "category": "Document category in German (e.g. Rechnung, Brief, Vertrag)"
        }
        Respond only with valid JSON. Do not write an introduction or summary.
      TEXT
      images: [img_b64]
    }
  end

  def generate_filename(analysis)
    date = analysis["main_date"].to_s
    date_prefix = Date.parse(date).strftime("%Y%m%d-") rescue ""

    sender = analysis["sender_name"].to_s.parameterize[0..30]
    category = analysis["category"].to_s.parameterize

    "#{date_prefix}#{sender}-#{category}.pdf"
  rescue => e
    "unknown-#{Time.now.strftime('%Y%m%d')}.pdf"
  end

  def output_debug(analysis)
    puts "\nDocument Analysis:"
    puts JSON.pretty_generate(analysis)
  end

  def rename(old_path, new_name)
    new_path = File.join(File.dirname(old_path), new_name)
    if @force
      FileUtils.mv(old_path, new_path)
      puts "Renamed to: #{new_name}"
    else
      puts "Suggestion: #{File.basename(old_path)} -> #{new_name}"
    end
  end

  def cleanup(path)
    File.delete(path) if File.exist?(path)
  end
end

options = { force: false, debug: true }
OptionParser.new do |opts|
  opts.banner = "Usage: ruby rename_pdfs.rb [DIRECTORY] [options]"
  opts.on("-f", "--force", "Actually rename files") { options[:force] = true }
  opts.on("--[no-]debug", "Show/hide analysis details") { |v| options[:debug] = v }
end.parse!

dir = ARGV[0] || "."
unless Dir.exist?(dir)
  puts "Directory not found: #{dir}"
  exit 1
end

PdfRenamer.new(
  directory: dir,
  force: options[:force],
  debug: options[:debug]
).run
