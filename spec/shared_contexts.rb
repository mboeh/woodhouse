#Celluloid.logger = nil

class FakeWorker

  class << self
    attr_accessor :last_worker
    attr_accessor :jobs

    def available_jobs
      [:foo, :bar]
    end
  end

  self.jobs ||= []

  def initialize
    FakeWorker.last_worker = self
    FakeWorker.jobs ||= []
  end

  def foo(args)
    FakeWorker.jobs << args
  end

  def bar(args)
    FakeWorker.jobs << args
  end

end

Woodhouse.configure do |config|
  config.registry = { :FooBarWorker => FakeWorker }
  config.runner_type = :dummy
  config.dispatcher_type = :local
  config.logger = Logger.new("/dev/null")
end

shared_examples_for "common" do

  let(:empty_layout) {
    Woodhouse::Layout.new
  }

  let(:populated_layout) {
    Woodhouse::Layout.new.tap do |layout|
      layout.add_node Woodhouse::Layout::Node.new(:default)
      layout.node(:default).tap do |default|
        default.add_worker Woodhouse::Layout::Worker.new(:FooWorker, :foo)
        default.add_worker Woodhouse::Layout::Worker.new(:FooWorker, :foo, :only => { :size => "huge" })
        default.add_worker Woodhouse::Layout::Worker.new(:FooWorker, :bar, :threads => 3)
      end
      layout.add_node Woodhouse::Layout::Node.new(:other)
      layout.node(:other).tap do |default|
        default.add_worker Woodhouse::Layout::Worker.new(:OtherWorker, :bat)
      end
    end
  }

  let(:overlapping_layout) {
    Woodhouse::Layout.new.tap do |layout|
      layout.add_node Woodhouse::Layout::Node.new(:default)
      layout.node(:default).tap do |default|
        default.add_worker Woodhouse::Layout::Worker.new(:FooWorker, :foo)
        default.add_worker Woodhouse::Layout::Worker.new(:FooWorker, :bar, :threads => 3)
        default.add_worker Woodhouse::Layout::Worker.new(:BarWorker, :baz)
      end
    end
  }

  let!(:common_config) {
    Woodhouse.global_configuration
  }

end
