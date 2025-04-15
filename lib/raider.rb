# frozen_string_literal: true

require 'zeitwerk'
require 'active_support/all'
require 'langchainrb'
require 'openai'
require 'base64'
require 'json'
require 'logger'
require 'fileutils'
require 'debug'

module Raider
  class << self
    attr_accessor :logger

    def root
      @root ||= Pathname.new(File.expand_path('..', __dir__))
    end
  end
end

Raider.logger = Logger.new(IO::NULL)
Raider.logger.level = Logger::FATAL
Langchain.logger.level = Logger::FATAL

Langchain.logger.level = Logger::INFO
Raider.logger = Logger.new($stdout)

loader = Zeitwerk::Loader.new
loader.tag = 'raider'
loader.logger = Raider.logger
loader.inflector.inflect(
  'llm' => 'LLM'
)

lib_path = Raider.root.join('lib')
loader.push_dir(lib_path)
loader.enable_reloading
# loader.log!
loader.setup
