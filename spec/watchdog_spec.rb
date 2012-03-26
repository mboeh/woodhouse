require 'woodhouse'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Woodhouse::Watchdog do
  it_should_behave_like "common"

  subject { Woodhouse::Watchdog }

  it "should notify listeners" do
    client = subject.register(:some_actor)
    queue = Queue.new
    Woodhouse::Watchdog.listen do |*info|
      queue << info
    end
    job = Woodhouse::Job.new(:FakeJob, :fake_method, "orz" => "vux")
    client.watch(job) {

    }
    notifications = []
    Timeout.timeout(5) {
      notifications << queue.pop
      notifications << queue.pop
    } rescue nil
    notifications.should have(2).items
  end

end
