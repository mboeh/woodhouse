require 'ganymede'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Ganymede::Scheduler do
  it_should_behave_like "common"

  subject { Ganymede::Scheduler.new(common_config) }

  let(:worker) {
    Ganymede::Layout::Worker.new(:FooBarWorker, :foo)
  }

  let(:worker_2) {
    Ganymede::Layout::Worker.new(:FooBarWorker, :foo, :only => { :job => "big" })
  } 

  if false
  it "should create a new worker set when a new worker is sent to #start_worker" do
    subject.start_worker worker
    subject.should be_running_worker(worker)
  end

  it "should not create a new worker set when an existing worker is sent to #start_worker" do
    pending "figure out how to test this without mocha, which works badly with Celluloid"
    subject.start_worker worker
    subject.start_worker worker
  end

  it "should spin down and remove a worker set when a worker is sent to #stop_worker" do
    subject.start_worker worker
    subject.stop_worker worker, true
    subject.should_not be_running_worker(worker)
  end
  end

  it "should spin down and remove all worker sets when #spin_down is called" do
    subject.start_worker worker
    subject.start_worker worker_2
    subject.spin_down
    subject.should_not be_running_worker(worker)
    subject.should_not be_running_worker(worker_2)
  end

end
