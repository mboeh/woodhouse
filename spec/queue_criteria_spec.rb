require 'woodhouse'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Woodhouse::QueueCriteria do
  it_should_behave_like "common"
  
  it "should stringify keys and values" do
    criteria = Woodhouse::QueueCriteria.new("abc" => :def, :fed => 1)
    criteria.criteria.should == { "abc" => "def", "fed" => "1" }
  end

  it "should expect all values to be matched" do
    criteria = Woodhouse::QueueCriteria.new(:orz => "*camper*", :spathi => "fwiffo")
    criteria.matches?("orz" => "*camper*").should be_false
    criteria.matches?("orz" => "*camper*", "spathi" => "fwiffo").should be_true
    criteria.matches?("orz" => "*camper*", "spathi" => "fwiffo", "vux" => "QRJ").should be_true
    criteria.exclusive = true
    criteria.matches?("orz" => "*camper*", "spathi" => "fwiffo", "vux" => "QRJ").should be_false
  end
end
