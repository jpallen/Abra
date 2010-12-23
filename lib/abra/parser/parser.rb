require File.join(File.dirname(__FILE__), 'expression_grammar')

module Abra
  class Parser < Treetop::Runtime::CompiledParser
    include ExpressionGrammar
    
    attr_accessor :options
    
    # Takes a string of TeX-like code and turns it into an internal
    # Abra Expression. You can configure the properties assigned to the
    # expression with Expression::Abra.set_default_options, or you can 
    # override any of the default properties by passing them as a 
    # second argument
    def self.parse(expression_string, properties = {})
      parser = self.new
      expression = parser.parse(expression_string).expression(properties)
      return expression
    end
  end
end
