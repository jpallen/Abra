module Abra
  module Expression
    class Index < Base
      # The letter or symbol used to display the index. This needs to be valid
      # LaTeX to display properly.
      attr_accessor :label
      
      # Can be either Index::POSITION_UP or Index::POSITION_DOWN depending on
      # whether the index should be displayed as a subscript or superscript.
      attr_accessor :position
      
      POSITION_UP = :up
      POSITION_DOWN = :down
      
      def position # :nodoc:
        @position ||= POSITION_DOWN
      end
      
      def position=(position) # :nodoc:
        unless [POSITION_UP, POSITION_DOWN].include?(position)
          raise ArgumentError, "position must be either Index::POSITION_UP or Index::POSITION_DOWN"
        end
        @position = position
      end
      
      # Another Index that this may be contracted with. Should be nil if the 
      # index is not contracted
      attr_accessor :contracted_with
      def contracted_with=(index) # :nodoc:
        unless index.is_a?(Index) or index.nil?
          raise ArgumentError, "can only contract with subclasses of Index"
        end
        @contracted_with = index
      end

      def initialize(options = {})
        self.label = options[:label] if options.has_key?(:label)
        self.position = options[:position] if options.has_key?(:position)
      end

      def inspect
        self.label
      end
    end
  end
end
