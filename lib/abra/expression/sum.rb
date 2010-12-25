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
      
      # Returns an array of DistributedIndex instances. These represent
      # the overall index structure of the sum and refer to the individual
      # indices on each term.
      #
      # There should never be any contractions between two indices on the same
      # sum since these would not be extracted from the constituent terms.
      # For example, (A^{a b}_a + B^{a b}_a) would only have b as a DistributedIndex,
      # It would not have [a,a,b] with the as contracted.
      # TODO: There is potential for subtle bugs here if two DistributedIndex instances
      # from the same sum are contracted after the expression is parsed.
      #
      # Note that modifying this array will not make any changes. Please use
      # the helper methods instead.
      def indices
        @indices ||= []
        return @indices.dup
      end
      
      # All indices from all terms, including the DistributedIndex instances
      # from the sum, and the component Index instances from each term in the sum
      def all_indices
        indices + self.terms.collect{|t| t.all_indices}.flatten
      end
      
      # Initialize a new Sum object and directly set its instance variables.
      # This should not be accessed directly as it can create expressions
      # in an inconsistent state.
      def initialize(attributes = {}) # :nodoc:
        @terms = attributes[:terms]
      end
      
      # Apply any properties passed when creating the expression.
      # Also extracts the overall index structure of the sum, so unless these
      # are set manually after or during initialization, this must be called
      # to put the sum in a consistent state.
      def apply_properties!(properties)
        @terms ||= []
        @indices = []
        unless @terms.empty?
          collect_indices_from_term!(@terms.first, :first_term => true)
          @terms[1..-1].each{|t| collect_indices_from_term! t }
        end
      end
      
      def load_from_serialization!(serialization, indices)
        @terms = serialization[:terms].collect{|t| Abra::Expression::Base.build_from_serialization(t, indices)}
        @indices = serialization[:indices].collect{|i| indices[i]}
      end
      
      # Inserts a term into the sum.
      # 
      # The term must be an instance of Expression. By default the term is inserted 
      # at the end of the sum but this can be overridden with the :position option. 
      # :position can be either :start, :end, or an integer.
      def insert_term!(term, properties = {})
        properties = {
          :position => :end
        }.merge(properties)
        
        unless term.is_a?(Expression::Wrapper)
          raise ArgumentError, "expected term to be an Expression but got #{term}"
        end
        
        position = properties[:position]
        if position == :start
          position = 0
        elsif position == :end
          position = self.terms.length
        elsif position > self.terms.length
          raise ArgumentError, "position exceeds number of terms"
        end
        
        @terms.insert(position, term)
        
        collect_indices_from_term!(term)
        
        return true
      end
      
      def inspect
        self.terms.map{|o| o.inspect}.join(' + ')
      end

      def to_hash
        {
          :type    => :sum,
          :terms   => self.terms.collect{|t| t.to_hash},
          :indices => self.indices
        }
      end
      
    private
      # Extracts the indices from a newly inserted term and links them into
      # the sum's DistributedIndex objects.
      def collect_indices_from_term!(term, options = {})
        options = {
          :first_term => false
        }.merge(options)
        
        remaining_distributed_indices = self.indices.dup
        for index in term.indices
          # Try to find an existing distributed index with this label and same position
          # if it matters
          distributed_index = remaining_distributed_indices.select{|i|
            match = (i.label == index.label)
            if index.position_matters? or i.position_matters?
              match = false if index.position != i.position
            end
            match
          }.first
          if distributed_index.nil?
            unless options[:first_term]
              Abra.logger.warn("The index '#{index.label}' is not present in all terms")
            end
            @indices ||= []
            distributed_index = DistributedIndex.new
            distributed_index.add_component_index!(index)
            @indices << distributed_index
          else
            remaining_distributed_indices.reject!{|i| i == distributed_index}
            distributed_index.add_component_index!(index)
          end
        end
        
        unless remaining_distributed_indices.empty?
          for index in remaining_distributed_indices
            Abra.logger.warn("The index '#{index.label}' is not present in all terms")
          end
        end
      end
    end
  end
end


