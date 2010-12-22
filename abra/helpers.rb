module Abra
  def self.e(string_expression)
    return Abra::Parser.new.parse(string_expression).expression
  end
end