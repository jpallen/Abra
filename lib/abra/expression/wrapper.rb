module Abra
  module Expression
    class Wrapper
      attr_reader :expression
      
      def initialize(klass, *options)
        @expression = klass.new(*options)
      end
      
      def method_missing(name, *options, &block)
        @expression.send(name, *options, &block)
      end

      def ==(other)
        self.expression == other.expression
      end

      def eql?(other)
        return false unless self.class == other.class
        self.expression.eql? other.expression
      end

      def hash
        self.class.hash ^ self.expression.hash
      end
      
      def inspect
        self.expression.inspect
      end
    end
  end
end

