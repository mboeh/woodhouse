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
    builder = Woodhouse::LayoutBuilder.new do |layout|
      layout.node(:default) do |default|
        default.all_workers :threads => 2
        default.remove :Cyril
        default.remove :Ray, :foo
        default.add    :Cyril, :bar, :only => { :baz => "bat" }
      end
      layout.node(:odin) do |odin|
        odin.add :Lana, :threads => 5
      end
    end
    layout = builder.layout
    layout.nodes.should have(2).nodes
    default = layout.node(:default)
    default.workers.should have(3).workers
    default.workers.first.threads.should == 2
    default.workers.map(&:worker_class_name).should_not include(:Cyril)
    default.workers.map(&:worker_class_name).should include(:Ray)
    default.workers.select{|wk|
      wk.worker_class_name == :Ray
    }.map(&:job_method).should_not include(:foo)
    cyrils = default.workers.select{|wk|
      wk.worker_class_name == :Cyril
    }
    cyrils.should have(1).worker
    cyrils.first.criteria.should == { :baz => "bat" }
    odin = layout.node(:odin)
    odin.workers.should have(1).worker
    odin.workers.first.threads.should == 5
  end

end
