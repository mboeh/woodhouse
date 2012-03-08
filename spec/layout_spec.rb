require 'ganymede'
require File.dirname(File.expand_path(__FILE__)) + '/shared_contexts'

describe Ganymede::Layout do

  context "#add_node" do

    it "should only accept Ganymede::Node objects"

  end

  context "#frozen_clone" do
      
    it "should return a frozen copy where all sub-objects are also frozen copies"

  end

  context "#changes_from" do
    
    it "should return a Ganymede::Layout::Changes object where this layout is the new one"

  end

end

describe Ganymede::Layout::Node do

  context "#default_configuration!" do

    it "should configure one worker thread for every job available"

  end

end

describe Ganymede::Layout::Worker do

  it "should default to 1 thread"

  it "should default to a wide-open criteria"

  it "should automatically convert the :only key to a Ganymede::QueueCriteria"

end

describe Ganymede::Layout::Changes do
  it_should_behave_like "common"

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
