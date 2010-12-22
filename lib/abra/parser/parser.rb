require File.join(File.dirname(__FILE__), 'expression_grammar')

module Abra
  class Parser < Treetop::Runtime::CompiledParser
    include ExpressionGrammar
    
    def self.parse(expression_string)
      self.new.parse(expression_string).expression
    end
  end
end
