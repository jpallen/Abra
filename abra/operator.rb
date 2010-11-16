module Abra
  class Operator < Expression
    attr_accessor :terms

    def terms
      @terms ||= []
    end
  end
end
