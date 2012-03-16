require 'woodhouse'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Woodhouse::QueueCriteria do
  it_should_behave_like "common"
  
  it "should stringify keys and values" do
    criteria = Woodhouse::QueueCriteria.new("abc" => :def, :fed => 1)
    criteria.criteria.should == { "abc" => "def", "fed" => "1" }
  end
end
