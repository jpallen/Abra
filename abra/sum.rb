class Sum < Operator
  def free_indices
    return [] if self.terms.empty?
    self.terms.first.free_indices
  end

  def insert_term(term)
    unless self.terms.empty?
      unless Index.free_indices_match?(term.free_indices, self.free_indices)
        raise Index::IndexInconsistency, "Free indices must match: #{term.free_indices.inspect} vs #{self.free_indices.inspect}"
      end
      term.replace_indices!(term.free_indices, self.free_indices)
    end

    self.terms << term

    return self
  end

  def inspect
    self.terms.map{|o| o.inspect}.join(' + ')
  end
end
