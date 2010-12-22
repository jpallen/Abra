require 'abra/logger'

require 'abra/expression/base'
require 'abra/expression/symbol'
require 'abra/expression/index'
require 'abra/expression/sum'
require 'abra/expression/product'


include Abra::Expression

@e = 
Product.new(:terms => [
  Abra::Expression::Symbol.new(:label => 'A', :indices => [
    Index.new(:label => 'a'),
    Index.new(:label => 'b'),
    Index.new(:label => 'c', :position => Index::POSITION_UP)
  ]),
  Abra::Expression::Symbol.new(:label => 'B', :indices => [
    Index.new(:label => 'a', :position => Index::POSITION_UP),
    Index.new(:label => 'b')
  ]),
  Abra::Expression::Symbol.new(:label => 'B', :indices => [
    Index.new(:label => 'a', :position => Index::POSITION_UP),
    Index.new(:label => 'c')
  ])
])

@e.contract_indices_based_on_labels!

