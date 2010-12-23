module Abra
  module Helpers
    def e(expression_string, options = {})
      return Abra::Parser.parse(expression_string, options)
    end
  end
end