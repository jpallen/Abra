module Abra
  module Expression
    # Represents the index structure arising from a sum of indexed terms.
    #
    # Consider an expression like (A^a + B^{a b} C_b) which has an overall index 
    # structure of ^a. If we call Sum#indices this will return an 
    # instance of DistributedIndex for each overall index. These point
    # to the indices on each term in the sum that contribute to the 
    # overall structure.
    # 
    # If we want to contract with the indices in a sum, we do so with the
    # DistributedIndex instances.
    class DistributedIndex < Index
      POSITION_MIXED = 'DistributedIndex::POSITION_MIXED'
      
      # An array of the index on each of the terms that contribute 
      # to this index in the overall index structure.
      attr_reader :component_indices
      def component_indices # :nodoc:
        @component_indices ||= []
        return @component_indices.dup
      end

      # Initialize a new DistributedIndex object and directly set its instance variables.
      # This should not be accessed directly as it can create expressions
      # in an inconsistent state.      
      def initialize(attributes = {})
        super
        @component_indices = attributes[:component_indices]
      end

      def to_hash
        {
          :type               => :distributed_index,
          :label              => self.label,
          :position           => self.position,
          :position_matters   => self.position_matters,
          :contracted_with    => self.contracted_with,
          :contracted_through => self.contracted_through,
          :component_indices  => self.component_indices
        }
      end

      def add_component_index!(index) # :nodoc:
        @component_indices ||= []
        @component_indices << index

        # Recalculate over all positions
        positions = @component_indices.collect{|i| i.position}.uniq
        if positions.size == 1
          @position = positions.first
        else
          @position = POSITION_MIXED
        end
        
        @position_matters = @component_indices.collect{|i| i.position_matters?}.include?(true)

        @label = @component_indices.first.label
      end
      
      def replace_index_ids_with_real_indices!(indices)
        @contracted_with       = @contracted_with.nil? ? nil : indices[@contracted_with]
        @contracted_through    = @contracted_through.nil? ? nil : indices[@contracted_through]
      end
    
    protected
      def set_contracted_with(index)
        @contracted_with = index
        for component_index in self.component_indices do
          component_index.set_contracted_with(index)
          component_index.set_contracted_through(self)
        end
      end
      
      def set_uncontracted
        self.component_indices.each{|i| i.set_uncontracted}
        @contracted_with    = nil
        @contracted_through = nil
      end
    end
  end
end
