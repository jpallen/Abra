module Abra
  module Expression
    class Index
      # The letter or symbol used to display the index. This needs to be valid
      # LaTeX to display properly.
      attr_accessor :label
      
      # Can be either Index::POSITION_UP or Index::POSITION_DOWN depending on
      # whether the index should be displayed as a subscript or superscript.
      attr_accessor :position
      
      POSITION_UP   = 'Index::POSITION_UP'
      POSITION_DOWN = 'Index::POSITION_DOWN'
      
      def position # :nodoc:
        @position ||= POSITION_DOWN
      end
      
      def position=(position) # :nodoc:
        unless [POSITION_UP, POSITION_DOWN].include?(position)
          raise ArgumentError, "position must be either Index::POSITION_UP or Index::POSITION_DOWN"
        end
        @position = position
      end
      
      # Set to true if the superscript or subscript property of the index 
      # if relevant to its meaning.
      attr_accessor :position_matters
      def position_matters=(value)
        @position_matters = !!value # Ensure boolean
      end
      
      # Is true if the superscript or subscript property of the index 
      # if relevant to its meaning.
      def position_matters?
        self.position_matters
      end
      
      # Another Index that this may be contracted with. Will be nil if the 
      # index is not contracted.
      attr_reader :contracted_with
      
      # If this index is on a term in a sum then the contraction will be done
      # with the DistributedIndex on the sum. This records that instance and allows
      # us to access it.
      attr_reader :contracted_through
      
      # Contract this index with another one. This will uncontract both indices
      # if already contracted, and then contract them with each other.
      def contract_with!(index)
        unless index.is_a?(Index)
          raise ArgumentError, "can only contract with subclasses of Index"
        end
        self.uncontract!
        index.uncontract!
        self.set_contracted_with(index)
        index.set_contracted_with(self)
      end
      
      # Removes any contraction between this index and another.
      def uncontract!(uncontract_other = true)
        if not self.contracted_through.nil?
          # Also takes care of uncontracting this
          self.contracted_through.uncontract!
        elsif not self.contracted_with.nil?  
          self.contracted_with.uncontract!(false) if uncontract_other
          self.set_uncontracted
        end
      end
      
      # Returns true if the index is contracted with another.
      # Otherwise returns false.
      def contracted?
        not @contracted_with.nil?
      end
      
      # Initialize a new Index object and directly set its instance variables.
      # This should not be accessed directly as it can create expressions
      # in an inconsistent state.
      def initialize(attributes = {}) # :nodoc:
        @label              = attributes[:label]
        @position           = attributes[:position]
        @position_matters   = attributes[:position_matters]
        @contracted_with    = attributes[:contracted_with]
        @contracted_through = attributes[:contracted_through]
      end
      
      # Apply any properties passed when creating the expression.
      def apply_properties!(properties)
        properties = Abra::Expression.default_properties.merge(properties)
      
        self.position_matters = !!properties[:index_position_matters]
        if properties[:index_position_matters_for].include?(self.label)
          self.position_matters = true
        elsif properties[:index_position_does_not_matter_for].include?(self.label)
          self.position_matters = false
        end
      end

      #def inspect
      #  self.label
      #end
      
      def to_hash
        {
          :type               => :index,
          :label              => self.label,
          :position           => self.position,
          :position_matters   => self.position_matters,
          :contracted_with    => self.contracted_with,
          :contracted_through => self.contracted_through
        }
      end
      
      def self.build_indices_from_serialization(serialized_indices)
        # Build up an index object for each index id
        indices = {}
        for index_id, index_hash in serialized_indices do
          type = index_hash.delete(:type)
          klass = eval(type.to_s.camelize)
          unless klass.ancestors.include?(Abra::Expression::Index)
            raise ArgumentError, "I can only build Abra::Expression::Index objects"
          end
          
          indices[index_id] = klass.new(
            serialized_indices[index_id]
          )
        end
        
        # The @contracted_with and @contracted_through variables are currently index ids,
        # so now replace them with the real indices we have.
        for index_id, index in indices
          index.replace_index_ids_with_real_indices!(indices)
        end
        
        return indices
      end
      
      def replace_index_ids_with_real_indices!(indices)
        @contracted_with       = @contracted_with.nil? ? nil : indices[@contracted_with]
        @contracted_through    = @contracted_through.nil? ? nil : indices[@contracted_through]
        @component_indices     ||= []
        @component_indices.map!{|i| indices[i]}
      end
      
    protected
      def set_contracted_with(index)
        @contracted_with = index
      end
      
      def set_contracted_through(index)
        @contracted_through = index
      end
      
      def set_uncontracted
        @contracted_with    = nil
        @contracted_through = nil
      end
    end
  end
end
