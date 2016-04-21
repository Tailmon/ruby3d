require 'singleton'
require 'logger'

module Ruby3d::Core::Logger
  class Log
    include Singleton

    def initialize
      @logger = Logger.new(STDOUT)
    end

    def info(class_name, msg)
      @logger.info(class_name) {msg}
    end

    def warn(class_name, msg)
      @logger.warn(class_name) {msg}
    end

    def fatal(class_name, msg)
      @logger.fatal(class_name) {msg}
    end
  end
end
