require 'woodhouse'

describe Woodhouse::Dispatchers::TestDispatcher do

  subject { Woodhouse::Dispatchers::TestDispatcher.new(Woodhouse::NodeConfiguration.new) }

  it "should store jobs" do
    subject.dispatch "PamPoovey", "shock_fights", "game_changer" => "yes"
    subject.dispatch "SterlingArcher", "spy", "on" => "Ramon Limon"

    subject.jobs.should have(2).items
    subject.jobs.first.worker_class_name.should == "PamPoovey"
  end

  it "should store job updates" do
    subject.update_job(:eating, "full" => "not yet")
    subject.job_updates.first.should == [ :eating, { "full" => "not yet" } ]
  end

end
