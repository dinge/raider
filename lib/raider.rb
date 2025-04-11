require "zeitwerk"
require "active_support/all"
require "langchainrb"
require "openai"
require "base64"
require "json"
require "logger"
require "fileutils"
require "debug"

module Raider
  class << self
    attr_accessor :logger

    def root
      @root ||= Pathname.new(File.expand_path("..", __dir__))
    end
  end
end


# Raider.logger = Logger.new($stdout)
Raider.logger = Logger.new(IO::NULL)
Raider.logger.level = Logger::FATAL
Langchain.logger.level = Logger::FATAL

loader = Zeitwerk::Loader.new
loader.tag = "raider"
loader.logger = Raider.logger
loader.inflector.inflect(
  "pdf_processor" => "PdfProcessor",
  "llm" => "LLM"
)

lib_path = Raider.root.join("lib")
loader.push_dir(lib_path)
loader.collapse("lib/raider/handlers/*")
loader.collapse("lib/raider/prompts/*")
loader.enable_reloading
# loader.log!
loader.setup
