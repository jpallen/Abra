module Abra
  class Logger
    attr_reader :messages
    def messages
      @messages ||= []
    end
    
    attr_accessor :log_level
    def log_level
      @log_level ||= INFO
    end
    
    DEBUG = 1
    INFO  = 2
    WARN  = 3
    ERROR = 4
    
    def log_level_word(level)
      {
         DEBUG => 'DEBUG',
         INFO  => 'INFO',
         WARN  => 'WARNING',
         ERROR => 'ERROR'
      }[level]
    end
    
    def log(message, level)
      messages << {
        :level   => level,
        :message => message,
        :time    => Time.now
      }
      if level >= log_level
        print "#{log_level_word(level)}: #{message}\n"
      end
    end
    
    def debug(message)
      log message, DEBUG
    end

    def info(message)
      log message, INFO
    end

    def warn(message)
      log message, WARN
    end

    def error(message)
      log message, ERROR
    end
  end
  
  def self.logger
    @logger ||= Logger.new
  end
end