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
          
          unless @terms.empty?
            collect_indices_from_term!(@terms.first, :first_term => true)
            @terms[1..-1].each{|t| collect_indices_from_term! t }
          end
        end
      end
      
      # Inserts a term into the sum.
      # 
      # The term must be an instance of Expression. By default the term is inserted 
      # at the end of the sum but this can be overridden with the :position option. 
      # :position can be either :start, :end, or an integer.
      def insert_term!(term, properties = {})
        properties = {
          :position => :end
        }.merge(options)
        
        unless term.is_a?(Expression::Base)
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
        
        self.collect_indices_from_term!(term)
      end
      
      def inspect
        self.terms.map{|o| o.inspect}.join(' + ')
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
            self.indices << DistributedIndex.new(:component_indices => [index])
          else
            remaining_distributed_indices.reject!{|i| i == index}
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


