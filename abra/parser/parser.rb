require File.join(File.dirname(__FILE__), 'expression_grammar')

module Abra
  class Parser < Treetop::Runtime::CompiledParser
    include ExpressionGrammar
  end
end
