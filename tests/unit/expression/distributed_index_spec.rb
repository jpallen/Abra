require File.join(File.dirname(__FILE__) + '/..', 'spec_helper')

describe Abra::Expression::DistributedIndex, '#position_matters' do
  it "should set position_matters = true if the component index position's matter" do
    e = Abra::Parser.parse('A_a + B_a', :index_position_matters => true)
    e.terms.first.indices.first.position_matters.should be_true
    e.indices.first.position_matters.should be_true
  end
  
  it "should set position_matters = false if the component index position's do not matter" do
    e = Abra::Parser.parse('A_a + B_a', :index_position_matters => false)
    e.indices.first.position_matters.should be_false
  end
end