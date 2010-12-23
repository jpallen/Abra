require File.join(File.dirname(__FILE__) + '/..', 'lib/abra')

Abra.logger.log_level = Abra::Logger::ERROR + 1 # Don't print anything

class BeContractedWith
  def initialize(contracted_index)
    @contracted_index = contracted_index
  end
  
  def matches?(source_index)
    @source_index = source_index
    return @source_index.contracted_with == @contracted_index
  end
  
  def description
    "be contracted with #{contracted_index}"
  end
  
  def failure_message
    " expected to be contracted with #{@contracted_index} but was contracted with: #{@source_index.contracted_with}"
  end
  
  def negative_failure_message
    " not expected to be contracted with #{@contracted_index}"
  end
end

def be_contracted_with(index)
  BeContractedWith.new(index)
end

class BeContracted
  def initialize
  end
  
  def matches?(source_index)
    @source_index = source_index
    return @source_index.contracted?
  end
  
  def description
    "be contracted"
  end
  
  def failure_message
    " expected to be contracted but was not"
  end
  
  def negative_failure_message
    " not expected to be contracted but was contracted with #{@source_index.contracted_with}"
  end
end

def be_contracted
  BeContracted.new
end

class Warn
  def initialize(message)
    @message = message
  end
  
  def matches?(block)
    old_messages = Abra.logger.messages.dup
    block.call
    @new_messages = Abra.logger.messages - old_messages
    for message in @new_messages do
      return true if message[:message] == @message and message[:level] == Abra::Logger::WARN
    end
    return false
  end
  
  def description
    "log a warning: #{@message}"
  end
  
  def failure_message
    " expected to log a warning: #{@message}\n" + 
    " but only got:\n #{@new_messages.select{|m| m[:level] == Abra::Logger::WARN}.collect{|m| "\t" + m[:message]}.join("\n")}\n"
  end
  
  def negative_failure_message
    " not expected to log a warning: #{@message}"
  end
end

def warn(index)
  Warn.new(index)
end