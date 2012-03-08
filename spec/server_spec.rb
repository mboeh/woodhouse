require 'ganymede'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Ganymede::Server do
  it_should_behave_like "common"

  subject { Ganymede::Server.new }

  it "should default to the :default node" do
    subject.node.should == :default
  end

  it "should expect the value to #layout= to be nil or a Layout" do
    subject.layout = Ganymede::Layout.new
    subject.layout.should be_kind_of Ganymede::Layout
    subject.layout = nil
    subject.layout.should be_nil
    expect do
      subject.layout = "foo"
    end.to raise_error
  end

  it "should take a frozen clone of the layout" do
    layout = Ganymede::Layout.new
    subject.layout = layout
    subject.layout.should_not be layout
    subject.layout.should be_frozen
  end

  context "#start" do
    
    it "should return false if a layout is not configured" do
      subject.start.should be_false
    end

    it "should return false if the set node doesn't exist in the layout" do
      subject.layout = populated_layout
      subject.node = :foo_bar_baz
      subject.start.should be_false
    end

    it "should return true and spin up workers if the node is valid" do
      subject.layout = populated_layout
      subject.start.should be_true
      # TODO: test for workers starting up
    end

  end

  context "#reload" do
    
    it "should shut down the server if a layout is not configured"

    it "should shut down the server if the set node doesn't exist in the layout"

    it "should shut down the server if the set node has no workers"

    it "should spin up new workers if they have been added to the node"

    it "should spin down workers if they have been removed from the node"

  end

end
