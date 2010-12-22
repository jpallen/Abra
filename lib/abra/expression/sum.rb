module Abra
  module Expression
    class Sum < Base
      # An array of expressions which make up the terms in the sum.
      # Note that modifying this array will not make any changes. Please use
      # the helper methods instead.
      attr_accessor :terms # :nodoc:
      def terms
        @terms ||= []
        return @terms.dup
      end
      
      def inspect
        self.terms.map{|o| o.inspect}.join(' + ')
      end
    end
  end
end


