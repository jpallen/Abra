require 'abra/expression'
require 'abra/atom'
require 'abra/operator'
require 'abra/product'
require 'abra/sum'
require 'abra/index'

@e = Abra::Product.new
@e.insert_term(
  Abra::Symbol.new(:label => 'g', :indices => [
    Index.new(:label => 'a'),
    Index.new(:label => 'b'),
    Index.new(:label => 'c')
  ])
)
@e.insert_term(
  Abra::Symbol.new(:label => 'X', :indices => [
    Index.new(:label => 'a')
  ])
)
