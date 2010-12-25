require File.join(File.dirname(__FILE__) + '/..', 'spec_helper')

describe Abra::Expression::Base, '#serialize' do
  it 'should map indices to integer ids' do
    e = Abra::Parser.parse('A_a B^a')
    s = e.serialize
    s[:indices].size.should eql 2
    index_ids = s[:indices].keys
    s[:indices][index_ids[0]][:contracted_with].should eql index_ids[1]
    s[:indices][index_ids[1]][:contracted_with].should eql index_ids[0]
  end
  
  it 'should set external index references to nil' do
    e = Abra::Parser.parse('A_a B^a')
    s = e.terms.first.serialize # Just the A
    s[:indices].size.should eql 1
    index_id = s[:indices].keys.first
    # We should not have references to contractions outside the 
    # serialized expression
    s[:indices][index_id][:contracted_with].should eql nil
  end
end

describe Abra::Expression::Base, 'eql?' do
  it 'should consider two different but equivalent expressions to be equal' do
    str = '(A_a + B_{a b} C^b) D^{a c} + E^c'
    e1 = Abra::Parser.parse(str)
    e2 = Abra::Parser.parse(str)
    e1.should eql e2
    e1.hash.should eql e2.hash
  end
  
  it 'should ignore external index contractions in comparisons' do
    e1 = Abra::Parser.parse('A_{a b}')
    e2 = Abra::Parser.parse('A_{a b} B^a C^b').terms[0]
    e3 = Abra::Parser.parse('A_{a b} + B_a C^b').terms[0]
    
    e2.should eql e1
    e2.hash.should eql e1.hash
    
    e3.should eql e1
    e3.hash.should eql e1.hash
  end
  
  it 'should compare index position' do
    e1 = Abra::Parser.parse('A_{a b}')
    e2 = Abra::Parser.parse('A_a^b')
    e1.should_not eql e2
    e1.hash.should_not eql e2.hash
  end
  
  it 'should compare index position properties' do
    e1 = Abra::Parser.parse('A_{a b}', :index_position_matters => true)
    e2 = Abra::Parser.parse('A_{a b}', :index_position_matters => false)
    
    e1.should_not eql e2
    # Why are these being equal? See comment in Base#hash
    #e1.hash.should_not eql e2.hash
  end
  
  it 'should compare contractions' do
    e1 = Abra::Parser.parse('A_a B^a', :contract_indices => true)
    e2 = Abra::Parser.parse('A_a B^a', :contract_indices => false)
    e1.should_not eql e2
    e1.hash.should_not eql e2.hash    
  end
end