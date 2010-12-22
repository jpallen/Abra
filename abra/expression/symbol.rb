module Abra
  module Expression
    class Symbol < Base
      # A string used when displaying the symbol. This needs to be valid
      # LaTeX to render properly.
      attr_accessor :label

      def initialize(options = {})
        self.label = options[:label] if options.has_key?(:label)
        self.indices = options[:indices] if options.has_key?(:label)
      end
      
      def inspect
        str = self.label
        # Write indices as S_{a b c}^{d e}_{f g}
        unless indices.empty?
          current_position = indices.first.position
          # Collect the indices into groups based on their position
          # In the above, we would end up with index_groups = [[a, b, c], [d, e], [f, g]]
          index_groups = [[]] 
          for index in indices
            if current_position == index.position
              index_groups.last << index
            else
              index_groups << [index] # new group
            end
            current_position = index.position
          end
          
          for index_group in index_groups
            str += index_group.first.position == Index::POSITION_UP ? '^{' : '_{'
            str += index_group.collect{|i| i.label}.join(' ')
            str += '}'
          end
        end
        return str
      end
    end
  end
end
