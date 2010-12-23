module Abra
  module Expression
    def self.system_default_properties
      {
        :index_position_matters             => false,
        :index_position_matters_for         => [],
        :index_position_does_not_matter_for => []
      }
    end
    
    # Set the default properties assigned to expressions when they are parsed
    # from a TeX-like string. Abra understands the following options:
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
    
    class Base
      # Returns an array of free indices at this level of the
      # expression. For example, in the expression F_{a b} G^b (assuming the bs are contracted), 
      # the whole expression has the indices [a], whereas the F has the 
      # indices [a, b]. How this is implemented will depend on the 
      # type of expression (Symbol, Sum, Product, etc).
      attr_reader :indices
      def indices # :nodoc:
        @indices ||= []
      end
    end
  end
end

