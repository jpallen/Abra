module Abra
  module Expression
    class Base
      # Returns an array of free indices at this level of the
      # expression. For example, in the expression F_{a b} G^b (assuming the bs are contracted), 
      # the whole expression has the indices [a], whereas the F has the 
      # indices [a, b]. How this is implemented will depend on the 
      # type of expression (Symbol, Sum, Product, etc).
      attr_reader :indices
      def indices # :nodoc:
        @indices ||= []
      end
    end
  end
end

