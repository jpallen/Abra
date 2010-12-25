require File.join(File.dirname(__FILE__) + '/../..', 'spec_helper')

describe Abra::Expression::Sum, 'distribued indices' do
  it 'should group indices with the same label' do
    e = Abra::Parser.parse('A_{a b} + B_{a}^{b}', :index_position_matters => false)
    # The bs should be contracted
    e.indices.size.should eql 2
    e.indices[0].label.should eql 'a'
    e.indices[0].position.should eql Abra::Expression::DistributedIndex::POSITION_DOWN
    e.indices[0].component_indices.should eql [e.terms.first.indices.first, e.terms.last.indices.first]
    e.indices[1].label.should eql 'b'
    e.indices[1].position.should eql Abra::Expression::DistributedIndex::POSITION_MIXED
    e.indices[1].component_indices.should eql [e.terms.first.indices.last, e.terms.last.indices.last]
  end
  
  it 'should group indices taking position into account if :index_position_matters is true' do
    e = Abra::Parser.parse('A_{a b} + B_{a}^{b}', :index_position_matters => true)
    # The bs should be contracted
    e.indices.size.should eql 3
    e.indices[0].label.should eql 'a'
    e.indices[0].position.should eql Abra::Expression::DistributedIndex::POSITION_DOWN
    e.indices[1].label.should eql 'b'
    e.indices[1].position.should eql Abra::Expression::DistributedIndex::POSITION_DOWN
    e.indices[2].label.should eql 'b'
    e.indices[2].position.should eql Abra::Expression::DistributedIndex::POSITION_UP
  end
  
  it 'should warn if indices are inconsistent across terms' do
    lambda {
      e = Abra::Parser.parse('A_{a} + B_{a}^{c}')
    }.should warn("The index 'c' is not present in all terms")
    
    lambda {
      e = Abra::Parser.parse('A_{a} + B^{a}', :index_position_matters => true)
    }.should warn("The index 'a' is not present in all terms")
  end
end