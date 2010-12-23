require File.join(File.dirname(__FILE__) + '/..', 'spec_helper')

describe 'Index contracted with Index' do
  before do
    @e = Abra::Parser.parse('A_a B^a')
    @e.contract_indices_based_on_labels!
  end
  
  it 'should set the correct contraction properties' do
    @e.terms.first.indices.first.should be_contracted_with(@e.terms.last.indices.first)
    @e.terms.last.indices.first.should be_contracted_with(@e.terms.first.indices.first)
  end
  
  it 'should uncontract correctly' do
    @e.terms.first.indices.first.uncontract!
    
    @e.terms.first.indices.first.should_not be_contracted
    @e.terms.last.indices.first.should_not be_contracted
  end
end

describe 'Index contracted with DistributedIndex' do
  before do
    @e = Abra::Parser.parse('(A_a + B_a) C^a')
    @e.contract_indices_based_on_labels!
    @sum = @e.terms.first
  end
  
  it 'should set the correct contraction properties' do
    @sum.indices.first.should be_contracted_with @e.terms.last.indices.first
    @e.terms.last.indices.first.should be_contracted_with @sum.indices.first
    
    # A_a and B_a should also have their indices contracted
    @sum.terms.first.indices.first.should be_contracted_with @e.terms.last.indices.first
    @sum.terms.first.indices.first.contracted_through.should eql @sum.indices.first
    
    @sum.terms.last.indices.first.should be_contracted_with @e.terms.last.indices.first
    @sum.terms.last.indices.first.contracted_through.should eql @sum.indices.first
  end
  
  it 'should uncontract correctly' do
    @e.terms.first.indices.first.uncontract!
    
    @sum.indices.first.should_not be_contracted
    @e.terms.last.indices.first.should_not be_contracted
    
    @sum.terms.first.indices.first.should_not be_contracted
    @sum.terms.first.indices.first.contracted_through.should eql nil
    
    @sum.terms.last.indices.first.should_not be_contracted
    @sum.terms.last.indices.first.contracted_through.should eql nil
  end
end


describe 'DistributedIndex contracted with DistributedIndex' do
  before do
    @e = Abra::Parser.parse('(A_a + B_a) (C^a + D^a)')
    @e.contract_indices_based_on_labels!
    @first_sum = @e.terms.first
    @second_sum = @e.terms.last
  end
  
  it 'should set the correct contraction properties' do
    @first_sum.indices.first.should be_contracted_with @second_sum.indices.first
    @second_sum.indices.first.should be_contracted_with @first_sum.indices.first
    
    # A_a and B_a should also have their indices contracted with the other sum
    @first_sum.terms.first.indices.first.should be_contracted_with @second_sum.indices.first
    @first_sum.terms.first.indices.first.contracted_through.should eql @first_sum.indices.first
    @first_sum.terms.last.indices.first.should be_contracted_with @second_sum.indices.first
    @first_sum.terms.last.indices.first.contracted_through.should eql @first_sum.indices.first
    
    # C^a and D^a should also have their indices contracted with the other sum
    @second_sum.terms.first.indices.first.should be_contracted_with @first_sum.indices.first
    @second_sum.terms.first.indices.first.contracted_through.should eql @second_sum.indices.first
    @second_sum.terms.last.indices.first.should be_contracted_with @first_sum.indices.first
    @second_sum.terms.last.indices.first.contracted_through.should eql @second_sum.indices.first
  end
  
  it 'should uncontract correctly' do
    @e.terms.first.indices.first.uncontract!
    
    @first_sum.indices.first.should_not be_contracted
    @second_sum.indices.first.should_not be_contracted
    
    # The A_a and B_a should also be set to uncontracted
    @first_sum.terms.first.indices.first.should_not be_contracted
    @first_sum.terms.first.indices.first.contracted_through.should eql nil
    @first_sum.terms.last.indices.first.should_not be_contracted
    @first_sum.terms.last.indices.first.contracted_through.should eql nil
    
    # The C^a and D^a should also be set to uncontracted
    @second_sum.terms.first.indices.first.should_not be_contracted
    @second_sum.terms.first.indices.first.contracted_through.should eql nil
    @second_sum.terms.last.indices.first.should_not be_contracted
    @second_sum.terms.last.indices.first.contracted_through.should eql nil
  end
end