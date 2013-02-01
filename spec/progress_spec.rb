require 'woodhouse/progress'

describe Woodhouse::Progress do

  describe "JobWithProgress" do
    subject { Object.new.tap do |obj| obj.extend Woodhouse::Progress::JobWithProgress end }

    it "should provide a method for creating a StatusTicker" do
      subject.status_ticker("orz").should be_kind_of(Woodhouse::Progress::StatusTicker)
    end

  end

  describe "StatusTicker" do
    let(:sink) { double("progress sink") }
    let(:job) { 
      Object.new.tap do |obj|
        obj.extend Woodhouse::Progress::JobWithProgress
        obj.progress_sink = sink
      end
    }

    it "should take initial status and tick arguments" do
      ticker = job.status_ticker("orz", :top => 100, :start => 10, :status => "working")
      ticker.to_hash.should == { "orz" => { "top" => 100, "current" => 10, "status" => "working" } }
    end

    context "#tick!" do
      
      it "should send progress updates" do
        ticker = job.status_ticker("orz")
        sink.should_receive(:update_job).with(job, { "orz" => { "status" => "funky", "current" => 1 } })
        ticker.tick! :status => "funky"
      end

    end

 end

end
