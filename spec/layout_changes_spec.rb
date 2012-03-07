require 'ganymede'

describe Ganymede::Layout::Changes do

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


  context "when the new layout is empty" do

    subject { Ganymede::Layout::Changes.new(empty_layout, populated_layout, :default) }

    it "should drop all workers and add none" do
      subject.adds.should be_empty
      subject.drops.should have(3).dropped_workers
    end

  end

  context "when the old layout is empty" do

    subject { Ganymede::Layout::Changes.new(populated_layout, empty_layout, :default) }

    it "should add all workers and drop none" do
      subject.drops.should be_empty
      subject.adds.should have(3).added_workers
    end

  end

  context "when the new layout is nil" do
    
    subject { Ganymede::Layout::Changes.new(nil, populated_layout, :default) }

    it "should drop all workers and add none" do
      subject.adds.should be_empty
      subject.drops.should have(3).dropped_workers
    end

  end

  context "when the old layout is nil" do

    subject { Ganymede::Layout::Changes.new(populated_layout, nil, :default) }

    it "should add all workers and drop none" do
      subject.drops.should be_empty
      subject.adds.should have(3).added_workers
    end

  end

  context "when both layouts are specified and they overlap" do

    subject { Ganymede::Layout::Changes.new(overlapping_layout, populated_layout, :default) }

    it "should add some workers, drop some, and leave some alone" do
      subject.drops.should have(1).dropped_worker
      subject.adds.should have(1).added_worker
    end

  end

end
