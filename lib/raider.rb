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
  VERSION = "0.2.9"

  class << self
    attr_accessor :logger


    def log(entry)
      # log/raider/#{@app.app_ident}--#{@current_task.ident}--#{@provider.provider_ident}-
      self.logger.info("#{'-' * 10} #{[entry.first].to_h} #{'-' * 70} ")
      self.logger.info(JSON.pretty_generate(entry))
    end

    def debug(entry)
      # log/raider/#{@app.app_ident}--#{@current_task.ident}--#{@provider.provider_ident}-
      self.logger.debug("#{'-' * 10} #{[entry.first].to_h} #{'-' * 70} ")
      self.logger.debug(JSON.pretty_generate(entry))
    end

    def run_task(task_ident, **args)
      app_options = (args.extract!(:app_options) || {}).fetch(:app_options, {})
      Raider::Apps::Base.new(app_options).create_task(task_ident.to_s.underscore.to_sym).process(**args)
    end

    def root
      @root ||= Pathname.new(File.expand_path('..', __dir__))
    end
  end
end

# Raider.logger = Logger.new(IO::NULL)
# Raider.logger.level = Logger::FATAL
# Langchain.logger.level = Logger::FATAL

if Rails.env.development?
  Raider.logger = Logger.new('log/raider/raider.log')
  Raider.logger.level = Logger::DEBUG
  Langchain.logger.level = Logger::DEBUG
else
  Raider.logger = Logger.new($stdout)
  Raider.logger.level = Logger::INFO
  Langchain.logger.level = Logger::INFO
end

# Langchain.logger = Logger.new('log/langchain.log', **Langchain::LOGGER_OPTIONS)

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
