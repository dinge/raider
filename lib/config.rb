require 'optparse'

module RenamePdfs
  class Config
    VALID_CATEGORIES = %w[Rechnung Brief Vertrag Mahnung Beleg Angebot misc]
    
    attr_reader :directory, :force, :debug, :provider, :dpi
    attr_reader :prompt_context

    def self.from_args(args = ARGV)
      new.tap { |config| config.parse_args(args) }
    end

    def initialize
      @force = false
      @debug = true
      @provider = :open_ai
      @dpi = 200
      @directory = "."
      @prompt_context = default_prompt_context
    end

    def parse_args(args)
      OptionParser.new do |opts|
        opts.banner = "Usage: ruby rename_pdfs.rb [DIRECTORY] [options]"
        opts.on("-f", "--force", "Actually rename files") { @force = true }
        opts.on("--[no-]debug", "Show/hide analysis details") { |v| @debug = v }
        opts.on("-p", "--provider PROVIDER", "LLM provider (llama3/gemma3/phi4/qwen2/open_ai)") { |v| @provider = v.to_sym }
      end.parse!(args)

      @directory = args[0] || "."
      validate_directory
    end

    private

    def validate_directory
      return if Dir.exist?(@directory)
      puts "Directory not found: #{@directory}"
      exit 1
    end

    def default_prompt_context
      {
        categories: VALID_CATEGORIES.join(", "),
        rules: [],
        custom_rules: [],
        additional_instructions: nil
      }
    end
  end
end