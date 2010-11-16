module Abra
  class Expression
    def replace_indices!(source_indices, target_indices)
      source_indices = source_indices.sort
      target_indices = target_indices.sort
      source_indices.each_index do |i|
        self.replace_index!(source_indices[i], target_indices[i])
      end
    end
  end
end

