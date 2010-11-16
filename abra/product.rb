module Abra
  class Product < Operator
    def free_indices
      self.terms.collect{|o| o.free_indices}.flatten 
    end

    def insert_term(term)
      for my_index in self.free_indices
        for term_index in term.free_indices
          if my_index.contractible_with?(term_index)
            my_index.contract_with(term_index)
          end
        end
      end

      self.terms << term

      return self
    end

    def inspect
      self.terms.map{|o| o.inspect}.join(' ')
    end
  end
end
