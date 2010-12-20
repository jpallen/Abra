module Abra
  module Expression
    class Product < Base
      # An array of expressions which make up the terms in the product.
      attr_accessor :terms # :nodoc:
      def terms
        @terms ||= []
      end
      
      def inspect
        self.terms.map{|o| o.inspect}.join(' ')
      end
    end
  end
end
