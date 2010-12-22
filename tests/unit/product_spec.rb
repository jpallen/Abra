require File.join(File.dirname(__FILE__) + '/..', 'spec_helper')

describe Abra::Expression::Product, '#contract_indices_based_on_labels' do
  it 'should contract indices with the same label' do
    e = Abra::Parser.parse('A_{a b} B_{b c}')
    e.contract_indices_based_on_labels!(:position_matters => false)
    # The bs should be contracted
    e.terms.first.indices.last.should be_contracted_with(e.terms.last.indices.first)
  end
  
  it 'should not contract indices on the same level when :position_matters is true' do
    e = Abra::Parser.parse('A_{a b} B_{b c}')
    e.contract_indices_based_on_labels!(:position_matters => true)
    e.terms.first.indices.last.should_not be_contracted_with(e.terms.last.indices.first)
  end
  
  it 'should contract indices on the different levels when :position_matters is true' do
    e = Abra::Parser.parse('A_{a b} B^{b c}')
    e.contract_indices_based_on_labels!(:position_matters => true)
    e.terms.first.indices.last.should be_contracted_with(e.terms.last.indices.first)
  end
  
  it 'should warn if there are more than 2 indices with one label' do
    e = Abra::Parser.parse('A_{a b} B^{a c} C_{a}')
    lambda {
      e.contract_indices_based_on_labels! 
    }.should warn("I found more than 2 indices with the label 'a' and don't know what to do")
  end
end