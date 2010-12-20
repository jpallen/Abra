module Abra
  module Expression
    class Symbol < Base
      # A string used when displaying the symbol. This needs to be valid
      # LaTeX to render properly.
      attr_accessor :label

      def initialize(options = {})
        self.label = options[:label] if options.has_key?(:label)
        self.indices = options[:indices] if options.has_key?(:label)
      end
      
      def inspect
        self.label
      end
    end
  end
end
