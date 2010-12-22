module Abra
  module Helpers
    def e(expression_string)
      return Abra::Parser.parse(expression_string)
    end
  end
end