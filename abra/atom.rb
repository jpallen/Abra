module Abra
  # This is just a helper class for drawing indices.
  class IndexGroup
    attr_accessor :indices, :position

    def position
      @position ||= Index::POSITION_DOWN
    end

    def indices
      @indices ||= []
    end

    def to_s
      if position == Index::POSITION_DOWN
        s = '_{'
      else
        s = '^{'
      end
      s += indices.map{|i| i.to_s}.join(' ')
      s += '}'
      return s
    end
  end

  class Symbol < Expression
    attr_accessor :label, :indices

    def initialize(options = {})
      self.label = options[:label] if options.has_key?(:label)
      self.indices = options[:indices] if options.has_key?(:label)
    end

    def indices
      @indices ||= []
    end

    def to_s
      s = label
      unless indices.empty?
        index_groups = []
        current_group = IndexGroup.new
        current_group.position = indices.first.position
        current_group.indices << indices.first
        for index in indices[1..-1]
          unless index.position == current_group.position
            index_groups << current_group
            current_group = IndexGroup.new
            current_group.position = index.position
          end
          current_group.indices << index
        end
        index_groups << current_group

        s += index_groups.map{|ig| ig.to_s}.join('')
      end

      return s
    end

    def free_indices
      self.indices.reject{|i| not i.free?}
    end

    def inspect
      self.to_s
    end

  protected
    def replace_index!(source_index, target_index)
      self.indices.each_index do |i|
        if self.indices[i] == source_index
          self.indices[i] = target_index
        end
      end
    end
  end
end
