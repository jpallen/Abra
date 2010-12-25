require File.join(File.dirname(__FILE__) + '/..', 'spec_helper')

describe Abra::Expression::Product, '#indices' do
  it 'should return any free indices at this level of the expression' do
    e = Abra::Parser.parse('(A_{a b}^{c} B_{c}^{a d} + C_{b}^{d}) D^{b}_{d}')
    prod = e.terms.first.terms.first
    # The free indices on the product of A and B are b and d, even though
    # these are contracted with terms outside this product. 
    prod.indices.collect{|i| i.label}.should eql ['b', 'd']
  end
end

describe Abra::Expression::Product, '#contract_indices_based_on_labels!' do
  it 'should contract indices with the same label' do
    e = Abra::Parser.parse('A_{a} B^{a b} C_b', :index_position_matters => false)
    # The bs should be contracted
    e.terms[0].indices[0].should be_contracted_with(e.terms[1].indices[0])
    e.terms[1].indices[1].should be_contracted_with(e.terms[2].indices[0])
  end
  
  it 'should not contract indices on the same level when :position_matters is true' do
    e = Abra::Parser.parse('A_{a b} B_{b c}', :index_position_matters => true)
    e.terms.first.indices.last.should_not be_contracted_with(e.terms.last.indices.first)
  end
  
  it 'should contract indices on the different levels when :position_matters is true' do
    e = Abra::Parser.parse('A_{a b} B^{b c}', :index_position_matters => true)
    e.terms.first.indices.last.should be_contracted_with(e.terms.last.indices.first)
  end
  
  it 'should warn if there are more than 2 indices with one label' do
    lambda {
      e = Abra::Parser.parse('A_{a b} B^{a c} C_{a}')
    }.should warn("I found more than 2 indices with the label 'a' which may cause inconsistent results")
  end
  
  it 'should not contract indices if :contract_indices is false' do
    e = Abra::Parser.parse('A_{a} B^{a b} C_b', :contract_indices => false)
    
    e.all_indices.each{|i| i.should_not be_contracted}
  end
end