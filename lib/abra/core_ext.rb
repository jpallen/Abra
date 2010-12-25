class Hash
  def replace_values!(options = {}, &block)
    for key in self.keys
      if (self[key].is_a?(Hash) or self[key].is_a?(Array)) and options[:recurse]
        self[key].replace_values!(options, &block)
      end
      self[key] = block.call(self[key])
    end
  end
end

class Array
  def replace_values!(options = {}, &block)
    for i in self.each_index do
      if (self[i].is_a?(Hash) or self[i].is_a?(Array)) and options[:recurse]
        self[i].replace_values!(options, &block)
      end
      self[i] = block.call(self[i])
    end
  end
end