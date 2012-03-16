require 'woodhouse'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Woodhouse::LayoutBuilder do
  it_should_behave_like "common"

  it "should provide a DSL to set up layouts" do
    registry = {
      :Pam   => FakeWorker,
      :Cyril => FakeWorker,
      :Ray   => FakeWorker,
      :Lana  => FakeWorker,
    }
    common_config.registry = registry
    builder = Woodhouse::LayoutBuilder.new(common_config) do |layout|
      layout.node(:default) do |default|
        # Eight workers...
        default.all_workers :threads => 2
        # Six workers...
        default.remove :Cyril
        # Five workers...
        default.remove :Ray, :foo
        # Six workers.
        default.add    :Ray, :bar, :only => { :baz => "bat" }
      end
      layout.node(:odin) do |odin|
        # Two workers.
        odin.add :Lana, :threads => 2
        # Still two workers
        odin.add :Lana, :threads => 5
      end
    end
    layout = builder.layout
    layout.nodes.should have(2).nodes
    default = layout.node(:default)
    default.workers.should have(6).workers
    default.workers.first.threads.should == 2
    default.workers.map(&:worker_class_name).should_not include(:Cyril)
    default.workers.map(&:worker_class_name).should include(:Ray)
    default.workers.select{|wk|
      wk.worker_class_name == :Ray
    }.map(&:job_method).should_not include(:foo)
    ray = default.workers.detect{|wk|
      wk.worker_class_name == :Ray && wk.criteria.criteria
    }
    ray.should_not be_nil
    ray.criteria.matches?(:baz => "bat").should be_true
    odin = layout.node(:odin)
    odin.workers.should have(2).workers
    odin.workers.first.threads.should == 5
  end

end
