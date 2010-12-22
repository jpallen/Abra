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
      
      def initialize(attributes = {})
        if attributes.has_key?(:terms)
          @terms = attributes[:terms]
          unless @terms.is_a?(Array) and @terms.select{|t| not t.is_a?(Abra::Expression::Base)}.empty?
            raise ArgumentError, "expected :terms to be an Array of Expressions"
          end
        end
      end
      
      # Tries to contract any indices that share the same label.
      # This method supports the following options:
      # * :position_matters - If true, will only contract an upper index with
      #   a lower index. If false, will contract any indices with the same label. 
      #   Default is true.
      def contract_indices_based_on_labels!(options = {})
        options = {
          :position_matters => true
        }.merge(options)
        indices = self.terms.collect{|t| t.indices}.flatten
        # Reject any indices which are already contracted
        # (including with indices outside this expression)
        indices.reject!{|i| i.contracted? }
        until indices.empty?
          index = indices.pop
          indices_with_same_label = indices.select{|i| i.label == index.label}
          if indices_with_same_label.size > 1
            Abra.logger.warn("I found more than 2 indices with the label #{index.label} and don't know what to do")
          elsif indices_with_same_label.size == 1
            contract_with = indices_with_same_label.first
            if (not options[:position_matters] or
                index.position != contract_with.position) # Only two positions so this is valid.
              #Abra.logger.debug("Contracting #{index} with #{contract_with}")
              index.contract_with!(contract_with)
            end
          end
          indices -= indices_with_same_label
        end
      end
      
      def inspect
        self.terms.map{|o| o.inspect}.join(' ')
      end
    end
  end
end
