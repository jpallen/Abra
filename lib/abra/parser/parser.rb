require File.join(File.dirname(__FILE__), 'expression_grammar')

module Abra
  class Parser < Treetop::Runtime::CompiledParser
    include ExpressionGrammar
    
    def self.parse(expression_string, options = {})
      expression = self.new.parse(expression_string).expression
      expression.sanitize!(options)
      return expression
    end
  end
end
