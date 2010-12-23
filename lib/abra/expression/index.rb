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
      
      # Another Index that this may be contracted with. Will be nil if the 
      # index is not contracted
      attr_reader :contracted_with
      
      # Contract this index with another one. This will uncontract both indices
      # if already contracted, and then contract them with each other.
      def contract_with!(index)
        unless index.is_a?(Index)
          raise ArgumentError, "can only contract with subclasses of Index"
        end
        self.uncontract!
        index.uncontract!
        @contracted_with = index
        index.instance_variable_set('@contracted_with', self)
      end
      
      # Removes any contraction between this index and another.
      def uncontract!
        unless self.contracted_with.nil?
          self.contracted_with.instance_variable_set('@contracted_with', nil)
          @contracted_with = nil
        end
      end
      
      # Returns true if the index is contracted with another.
      # Otherwise returns false.
      def contracted?
        not @contracted_with.nil?
      end

      def initialize(options = {})
        self.label = options[:label] if options.has_key?(:label)
        self.position = options[:position] if options.has_key?(:position)
      end
      
      def sanitize!(options = {})
        # Nothing needs doing
      end

      def inspect
        self.label
      end
    end
  end
end
