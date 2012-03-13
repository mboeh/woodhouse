require 'woodhouse'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Woodhouse::Worker do

  subject {
    Class.new do
      include Woodhouse::Worker
      def fake_job(*); end
    end
  }

  it "should provide class-level async_ convenience methods" do
    lambda do
      subject.async_fake_job
    end.should_not raise_error(NoMethodError)
    lambda do
      subject.async_something_else
    end.should raise_error(NoMethodError)
    lambda do
      subject.blah_blah_blah
    end.should raise_error(NoMethodError)
    lambda do
      subject.async_method # Don't want inherited methods to work
    end.should raise_error(NoMethodError)
  end

end
