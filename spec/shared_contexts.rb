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


end
