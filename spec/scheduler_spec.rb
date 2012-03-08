require 'ganymede'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Ganymede::Scheduler do
  it_should_behave_like "common"

  subject { Ganymede::Scheduler.new }

  let(:worker) {
    Ganymede::Layout::Worker.new(:FooBarWorker, :foo)
  }

end
