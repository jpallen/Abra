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
      
      def initialize(attributes = {})
        if attributes.has_key?(:component_indices)
          unless attributes[:component_indices].is_a?(Array) and attributes[:component_indices].select{|i| not i.is_a?(Index)}.empty?
            raise ArgumentError, "expected :component_indices to be an Array of Index instances"
          end
          
          attributes[:component_indices].each{|i| self.add_component_index! i }
        end
      end
    
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
      
      def add_component_index!(index) # :nodoc:
        @component_indices ||= []
        @component_indices << index
        
        # Recalculate over all position
        positions = @component_indices.collect{|i| i.position}.uniq
        if positions.size == 1
          @position = positions.first
        else
          @position = POSITION_MIXED
        end
        
        @label = @component_indices.first.label
      end
    end
  end
end
