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
      
      def initialize(attributes = {})
        if attributes.has_key?(:terms)
          @terms = attributes[:terms]
          unless @terms.is_a?(Array) and @terms.select{|t| not t.is_a?(Expression::Base)}.empty?
            raise ArgumentError, "expected :terms to be an Array of Expressions"
          end
        end
      end
      
      # Inserts a term into the sum.
      # 
      # The term must be an instance of Expression. By default the term is inserted 
      # at the end of the sum but this can be overridden with the :position option. 
      # :position can be either :start, :end, or an integer.
      def insert_term!(term, options = {})
        options = {
          :position => :end,
          :sanitize => true
        }.merge(options)
        
        unless term.is_a?(Expression::Base)
          raise ArgumentError, "expected term to be an Expression but got #{term}"
        end
        
        position = options[:position]
        if position == :start
          position = 0
        elsif position == :end
          position = self.terms.length
        elsif position > self.terms.length
          raise ArgumentError, "position exceeds number of terms"
        end
        
        @terms.insert(position, term)
      end
      
      # Looks through the index structure of each term and creates an overall
      # array of DistributedIndex objects representing the overall index
      # structure of the sum.
      def extract_distributed_indices_based_on_labels!(options = {})
        options = {
          :position_matters => false
        }.merge(options)
        
        index_groups = []
        for term in terms do
          for index in term.indices
            index_matched = false
            for index_group in index_groups
              if index.label == index_group.first.label
                unless options[:position_matters] and index.position != index_group.first.position
                  index_group << index
                  index_matched = true
                  break
                end
              end
            end
            unless index_matched
              index_groups << [index]
            end
          end
        end
        
        @indices = []
        for index_group in index_groups
          unless index_group.size == terms.size
            Abra.logger.warn("The index '#{index_group.first.label}' is not consistant across all terms")
          end
          
          @indices << DistributedIndex.new(:component_indices => index_group)
        end
      end
      
      def sanitize!(options = {})
        self.terms{|t| t.sanitize!(options)}
        self.extract_distributed_indices_based_on_labels!(options)
      end
      
      def inspect
        self.terms.map{|o| o.inspect}.join(' + ')
      end
    end
  end
end


