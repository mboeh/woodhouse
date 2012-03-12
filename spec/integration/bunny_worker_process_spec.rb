require 'woodhouse'
require File.dirname(File.expand_path(__FILE__)) + '/../shared_contexts'

describe Woodhouse::BunnyWorkerProcess do
  it_should_behave_like "common"

  let(:scheduler) {
    Woodhouse::Scheduler.new(common_config)
  }

  let(:worker) {
    Woodhouse::Layout::Worker.new(:FooBarWorker, :foo, :only => { :orz => "*happy campers*" })
  }

  it "should pull jobs off a queue" do
    scheduler.start_worker worker
    sleep 0.5
    # TODO: this should use the bunny dispatcher, once I write it
    bunny = Bunny.new
    bunny.start
    exchange = bunny.exchange(worker.exchange_name, :type => :headers)
    exchange.publish("hi", :headers => { :orz => "*happy campers*" })
    exchange.publish("hi", :headers => { :orz => "*silly cows*" })
    bunny.stop
    sleep 0.2
    FakeWorker.jobs.should have(1).job
    FakeWorker.jobs.last[:orz].should == "*happy campers*"
    scheduler.spin_down
  end

end
