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
  VERSION = "0.2.5"

  class << self
    attr_accessor :logger

    def log(entry)
      # log/raider/#{@app.app_ident}--#{@current_task.ident}--#{@provider.provider_ident}-
      self.logger.info(JSON.pretty_generate(entry))
    end

    def debug(entry)
      # log/raider/#{@app.app_ident}--#{@current_task.ident}--#{@provider.provider_ident}-
      self.logger.debug(JSON.pretty_generate(entry))
    end

    def root
      @root ||= Pathname.new(File.expand_path('..', __dir__))
    end
  end
end

# Raider.logger = Logger.new(IO::NULL)
# Raider.logger.level = Logger::FATAL
# Langchain.logger.level = Logger::FATAL

Raider.logger = Logger.new('log/raider/raider.log')

# Raider.logger = Logger.new($stdout)
Raider.logger.level = Logger::DEBUG

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
