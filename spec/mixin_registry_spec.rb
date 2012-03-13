require 'woodhouse'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Woodhouse::MixinRegistry do

  subject { Woodhouse::MixinRegistry.new }

  it "should include all classes that include Woodhouse::Worker" do
    ::SomeFakeNewClass = Class.new
    SomeFakeNewClass.send(:include, Woodhouse::Worker)
    subject[:SomeFakeNewClass].should be SomeFakeNewClass
    Object.send :remove_const, :SomeFakeNewClass
  end

end
