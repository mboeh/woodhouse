require 'woodhouse'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Woodhouse::NodeConfiguration do
  it_should_behave_like "common"

  subject { Woodhouse::NodeConfiguration.new }

  describe "server_info" do
    
    it "should default to an empty hash" do
      subject.server_info.should == {}
    end

    it "should convert keys into symbols" do
      subject.server_info = { "lana" => "LANAAAA" }
      subject.server_info.should have_key(:lana)
    end

  end

end
