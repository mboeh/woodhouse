require 'woodhouse'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Woodhouse::MiddlewareStack do
  it_should_behave_like "common"

  subject { Woodhouse::MiddlewareStack.new(common_config) }
  let(:dummy) { MiddlewareDummy.new }

  class MiddlewareDummy
    attr_reader :was_called, :sent_item
    def initialize
      @was_called = false
      @sent_item  = nil
    end

    def call(job)
      @was_called = true
      @sent_item = job
      yield job
    end

  end

  it "should work if empty" do
    called = :not_called
    subject.call("LANAAAA!") {|object|
      object.should == "LANAAAA!"
      called = :called
    }
    called.should == :called
  end

  it "should send #call to stack items which respond to that" do
    subject << dummy
    subject.call("is it not?") {|object| }
    dummy.was_called.should be_true
    dummy.sent_item.should == "is it not?"
  end

  it "should send #new to stack items which respond to that" do
    fake_class = stub('mware item', :new => dummy)
    subject << fake_class
    subject.call("danger zone") {|object| }
    dummy.was_called.should be_true
    dummy.sent_item.should == "danger zone"
  end

  it "should complain with ArgumentError if entries respond to neither #call nor #new" do
    subject << nil
    expect do
      subject.call("danger zone") {|object| }
    end.to raise_error(ArgumentError)
  end

end
