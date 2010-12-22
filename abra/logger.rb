module Abra
  class Logger
    def warn(message)
      print "WARNING: #{message}\n"
    end
    
    def debug(message)
      print "DEBUG: #{message}\n"
    end
  end
  
  def self.logger
    @logger ||= Logger.new
  end
end