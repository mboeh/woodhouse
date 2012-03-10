#Celluloid.logger = nil

class FakeWorker

  class << self
    attr_accessor :last_worker
    attr_accessor :jobs
  end

  def initialize
    FakeWorker.last_worker = self
    FakeWorker.jobs ||= []
  end

  def foo(args)

    FakeWorker.jobs << args
  end

end

require 'ganymede/bunny_worker_process' 

shared_examples_for "common" do

  let(:empty_layout) {
    Ganymede::Layout.new
  }

  let(:populated_layout) {
    Ganymede::Layout.new.tap do |layout|
      layout.add_node Ganymede::Layout::Node.new(:default)
      layout.node(:default).tap do |default|
        default.add_worker Ganymede::Layout::Worker.new(:FooWorker, :foo)
        default.add_worker Ganymede::Layout::Worker.new(:FooWorker, :foo, :only => { :size => "huge" })
        default.add_worker Ganymede::Layout::Worker.new(:FooWorker, :bar, :threads => 3)
      end
      layout.add_node Ganymede::Layout::Node.new(:other)
      layout.node(:other).tap do |default|
        default.add_worker Ganymede::Layout::Worker.new(:OtherWorker, :bat)
      end
    end
  }

  let(:overlapping_layout) {
    Ganymede::Layout.new.tap do |layout|
      layout.add_node Ganymede::Layout::Node.new(:default)
      layout.node(:default).tap do |default|
        default.add_worker Ganymede::Layout::Worker.new(:FooWorker, :foo)
        default.add_worker Ganymede::Layout::Worker.new(:FooWorker, :bar, :threads => 3)
        default.add_worker Ganymede::Layout::Worker.new(:BarWorker, :baz)
      end
    end
  }

  let(:common_config) {
    Ganymede::NodeConfiguration.new do |config|
      config.registry = { :FooBarWorker => FakeWorker }
      config.worker_type = Ganymede::BunnyWorkerProcess
    end
  }

end
