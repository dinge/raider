# frozen_string_literal: true

require 'zeitwerk'
require 'active_support/all'
require 'langchainrb'
require 'openai'
require 'base64'
require 'json'
require 'logger'
require 'fileutils'
require 'recursive_open_struct'
require 'debug'


module Raider
  VERSION = "0.2.3"

  class << self
    attr_accessor :logger

    def root
      @root ||= Pathname.new(File.expand_path('..', __dir__))
    end
  end
end

# Raider.logger = Logger.new(IO::NULL)
# Raider.logger.level = Logger::FATAL
# Langchain.logger.level = Logger::FATAL

Raider.logger = Logger.new($stdout)
Raider.logger.level = Logger::INFO
Langchain.logger.level = Logger::DEBUG

# Langchain.logger = Logger.new('log/langchain.log', **Langchain::LOGGER_OPTIONS)
Langchain.logger.level = Logger::DEBUG

loader = Zeitwerk::Loader.new
loader.tag = 'raider'
loader.logger = Raider.logger
loader.inflector.inflect(
  'llm' => 'LLM'
)

loader.push_dir(Raider.root.join('lib'))
loader.enable_reloading
# loader.log!
loader.setup

require 'raider/railtie' if defined?(Rails::Railtie)
