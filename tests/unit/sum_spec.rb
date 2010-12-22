require File.join(File.dirname(__FILE__) + '/..', 'spec_helper')

describe Abra::Expression::Sum, '#group_indices_based_on_labels!' do
  it 'should group indices with the same label' do
    e = Abra::Parser.parse('A_{a b} + B_{a}^{b}')
    e.group_indices_based_on_labels!(:position_matters => false)
    # The bs should be contracted
    e.indices.size.should eql 2
    e.indices[0].label.should eql 'a'
    e.indices[0].position.should eql Abra::Expression::DistributedIndex::POSITION_DOWN
    e.indices[1].label.should eql 'b'
    e.indices[1].position.should eql Abra::Expression::DistributedIndex::POSITION_MIXED
  end
  
  it 'should group indices taking position into account if :position_matters is true' do
    e = Abra::Parser.parse('A_{a b} + B_{a}^{b}')
    e.group_indices_based_on_labels!(:position_matters => true)
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
    e = Abra::Parser.parse('A_{a} + B_{a}^{c}')
    lambda {
      e.group_indices_based_on_labels!
    }.should warn("The index 'c' is not consistant across all terms")
    
    e = Abra::Parser.parse('A_{a} + B^{a}')
    lambda {
      e.group_indices_based_on_labels!(:position_matters => true)
    }.should warn("The index 'a' is not consistant across all terms")
  end
end