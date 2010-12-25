module Abra
  module Expression
    class Product < Base
      # An array of expressions which make up the terms in the product.
      # Note that modifying this array will not make any changes. Please use
      # the helper methods instead.
      attr_accessor :terms # :nodoc:
      def terms
        @terms ||= []
        return @terms.dup # Don't give access to the actual array
      end
      
      # Initialize a new Product object and directly set its instance variables.
      # This should not be accessed directly as it can create expressions
      # in an inconsistent state.
      def initialize(attributes = {}) # :nodoc:
        @terms = attributes[:terms]
      end
      
      # Apply any properties passed when creating the expression.
      # Currently this is just figuring out which indices should be 
      # contrated.
      def apply_properties!(properties)
        contract_indices!(properties)
      end

      def load_from_serialization!(serialization, indices)
        @terms = serialization[:terms].collect{|t| Abra::Expression::Base.build_from_serialization(t, indices)}
      end
      
      # Returns the free indices at this level of the expression. These indices
      # may be contracted with other indices at a higher level in the expression,
      # but this is not relevant for the free indices of this term.
      def indices
        all_indices = self.terms.collect{|i| i.indices}.flatten
        free_indices = []
        for index in all_indices
          free_indices << index unless all_indices.include?(index.contracted_with)
        end
        return free_indices
      end
      
      # Returns all indices from all terms, both free and contracted
      def all_indices
        self.terms.collect{|i| i.all_indices}.flatten
      end
      
      # Inserts a term into the product.
      # 
      # The term must be an instance of Expression. By default the term is inserted 
      # at the end of the product but this can be overridden with the :position option. 
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
                
        contract_indices!(properties)
      end
      
      def inspect
        self.terms.map{|t| 
          if t.expression.is_a?(Sum)
            "(#{t.inspect})"
          else 
            t.inspect
          end
        }.join(' ')
      end
      
      def to_hash
        {
          :type  => :product,
          :terms => self.terms.collect{|t| t.to_hash}
          # indices are worked out from the indices on the terms
        }
      end
      
    private
      
      # Tries to contract any uncontracted indices in the product based on the
      # index properties and any additional properties passed.
      def contract_indices!(properties = {})
        properties = Abra::Expression.default_properties.merge(properties)
        # Reject any indices which are already contracted
        # (including with indices outside this expression)
        indices = self.terms.collect{|i| i.indices}.flatten
        until indices.empty?
          index = indices.first 
          indices_with_same_label = indices.select{|i| i.label == index.label}
          if indices_with_same_label.size > 2
            Abra.logger.warn("I found more than 2 indices with the label '#{index.label}' which may cause inconsistent results")
          else
            uncontracted_indices_with_same_label = indices_with_same_label.reject{|i| i.contracted? }
            if uncontracted_indices_with_same_label.size == 2
              index         = uncontracted_indices_with_same_label.first
              contract_with = uncontracted_indices_with_same_label.last

              # Check if we should be contracting these indices based on the 
              # :contract_indices properties.
              should_contract = !!properties[:contract_indices]
              if properties[:contract_indices_for].include?(index.label)
                should_contract = true
              elsif properties[:do_not_contract_indices_for].include?(index.label)
                should_contract = false
              end

              # Check if we can contract them based on position
              if index.position_matters? or contract_with.position_matters?
                # We need one index to be up and the other down if we are to contract
                if [index.position, contract_with.position].sort != [Index::POSITION_UP, Index::POSITION_DOWN].sort
                  should_contract = false
                end
              end

              if should_contract
                index.contract_with!(contract_with)
              end
            end
          end
          indices -= indices_with_same_label
        end
      end
    end
  end
end
