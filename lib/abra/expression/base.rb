module Abra
  module Expression
    def self.system_default_properties
      {
        :contract_indices                   => true,
        :contract_indices_for               => [],
        :do_not_contract_indices_for        => [],
        :index_position_matters             => false,
        :index_position_matters_for         => [],
        :index_position_does_not_matter_for => []
      }
    end
    
    # Set the default properties assigned to expressions when they are parsed
    # from a TeX-like string. Abra understands the following options:
    # * :contract_indices - true or false depending on whether indices with the same
    #   label should be automatically contracted. This should be true unless you have 
    #   good reason to do otherwise.
    # * :contract_indices_for - An Array of index labels which should be automatically
    #   contracted.
    # * :do_not_contract_indices_for - An Array of index labels which should not be 
    #   automatically contracted.
    # * :index_position_matters - true or false depending on whether the position
    #   of indices as subscript or superscript is relevant. This can be 
    #   overridden on an index by index basis with :position_matters_for
    #   and position_does_not_matter_for.
    # * :index_position_matters_for - An Array of index labels for which the subscript
    #   or superscript property is important.
    # * :index_position_does_not_matter_for - An Array of index labels for which 
    #   the subscript or superscript property is unimportant.
    def self.set_default_properties(options)
      @default_properties = self.default_properties.merge(options)
    end
    
    def self.default_properties
      @default_properties ||= self.system_default_properties
    end
    
    def self.new_from_serialization(serialization)
      indices = Index.build_indices_from_serialization(serialization[:indices])
      expression = Base.build_from_serialization(serialization[:expression], indices)
      return expression
    end
    
    class Base
      # Returns an array of free indices at this level of the
      # expression. For example, in the expression F_{a b} G^b (assuming the bs are contracted), 
      # the whole expression has the indices [a], whereas the F has the 
      # indices [a, b]. How this is implemented will depend on the 
      # type of expression (Symbol, Sum, Product, etc).
      attr_reader :indices
      def indices # :nodoc:
        raise NotImplementedError, "#{subclass} needs to override indices"
      end
      
      # Recurses through the expression and returns all indices, contracted 
      # or free, that are part of the expression.
      def all_indices
        raise NotImplementedError, "#{subclass} needs to override all_indices"
      end
      
      def to_hash
        raise NotImplementedError, "#{subclass} needs to override to_hash"
      end
      
      # Returns a representation of the expression using native Ruby
      # objects (Array, Hash, Fixnum, etc). The tree-like structure of 
      # the expression is stored as a Hash. The indices are stored seperately
      # and references via integer ids. This allows contraction properties to be 
      # stored.
      #
      # For example,
      # >> Abra::Parser.parse('(A_{a b} B^b + C_a) D^a').serialize
      # =>  {
      #       :expression => {
      #         :type => :product,
      #         :terms => [
      #           {
      #             :type => :sum,
      #             :terms => [...],
      #             :indices => [5]
      #           },
      #           {
      #             :type => :symbol,
      #             :label => 'C',
      #             :indices => [6]
      #           }
      #         ]
      #       },
      #       :indices => {
      #         1 => {:type => :index, :label => 'a', :contracted_with => 6, :contracted_through => 5},
      #         2 => {:type => :index, :label => 'b', :contracted_with => 3, :contracted_through => nil},
      #         3 => {:type => :index, :label => 'b', :contracted_with => 2, :contracted_through => nil},
      #         4 => {:type => :index, :label => 'a', :contracted_with => 6, :contracted_through => 5},
      #         5 => {:type => :distributed_index, :label => 'a', :contracted_with => 6, :contracted_through => nil,
      #               :component_indices => [1,4]},
      #         6 => {:type => :index, :label => 'a', :contracted_with => 5, :contracted_through => nil}
      #       }
      #     }
      def serialize
        all_indices = self.all_indices
        # Create a hash where each key is an Index pointing to its unique id value
        id = 0
        index_ids = Hash[*all_indices.collect{|i| [i, id += 1]}.flatten] 
        
        # Create a hash where each key is the index id pointing to the serialized version of itself
        serialized_indices = Hash[*all_indices.collect{|i| [index_ids[i], i.to_hash]}.flatten]

        serialized_expression = self.to_hash
        
        for hash in [serialized_indices, serialized_expression] do
          # The only non-native objects left in these hashes are references to other
          # Index objects via contracts. We replace them all with the corresponding index id.
          hash.replace_values!(:recurse => true) {|v|
            if v.is_a?(Index)
              if all_indices.include?(v)
                index_ids[v]
              else
                nil # reference to an index outside the expression
              end
            else
              v # Not an index so just leave it be
            end
          }
        end
        
        return {
          :expression => serialized_expression,
          :indices    => serialized_indices
        }
      end
      
      def self.build_from_serialization(serialization, indices)
        type = serialization.delete(:type)
        klass = eval(type.to_s.camelize)
        unless klass.ancestors.include?(Abra::Expression::Base)
          raise ArgumentError, "I can only build Abra::Expression objects from a serialization"
        end
        expression = Abra::Expression::Wrapper.new(klass)
        expression.load_from_serialization!(serialization, indices)
        return expression
      end

      def ==(other)
        self.eql?(other)
      end

      def eql?(other)
        return false unless self.class == other.class
        self.serialize == other.serialize
      end

      def hash
        # These will collide sometimes due to {0 => false}.hash == {1 => true}.hash
        self.class.hash ^ self.serialize.hash
      end
    end
  end
end

