module Abra
  class Index
    POSITION_UP = :up
    POSITION_DOWN = :down

    STATE_FREE = :free
    STATE_CONTRACTED = :contracted

    class IndexInconsistency < RuntimeError; end

    attr_accessor :label, :position, :state, :contracted_with
    protected :contracted_with=

    class << self
      def free_indices_match?(first_set, second_set)
        return false unless first_set.length == second_set.length
        first_set = first_set.sort
        second_set = second_set.sort
        first_set.each_index do |i|
          first_index = first_set[i]
          second_index = second_set[i]
          raise Index::InconsistentIndices, "#{first_index} is not a free index" unless first_index.free?
          raise Index::InconsistentIndices, "#{second_index} is not a free index" unless second_index.free?
          
          return false unless first_index.label == second_index.label
        end
        return true
      end
    end

    def initialize(options = {})
      self.label = options[:label] if options.has_key?(:label)
      self.position = options[:position] if options.has_key?(:position)
      self.state = STATE_FREE
    end

    def free?
      self.state == STATE_FREE
    end

    def contractible_with?(index)
      # Eventually check for up and down properties
      return true if index.free? and self.free? and index.label == self.label
      return false
    end

    def contract_with(index)
      self.state  = STATE_CONTRACTED
      index.state = STATE_CONTRACTED
      self.contracted_with  = index
      index.contracted_with = self
    end

    def label
      @label ||= '.'
    end

    def label=(label)
      @label = label
      if self.state == STATE_CONTRACTED
        self.contracted_with.instance_variable_set('@label', @label)
      end
    end

    def position
      @position ||= POSITION_DOWN
    end

    def to_s
      label
    end

    def inspect
      self.to_s
    end

    def <=>(index)
      return 0 unless index.is_a?(Index)
      self.label <=> index.label
    end
  end
end
