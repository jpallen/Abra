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