require 'poovey'

describe Poovey do

  context "[]" do

    it "should create a Poovey::Criteria" do
      expect(Poovey["pam", "white" => "pumpkin"]).to eq Poovey::Criteria.new("pam", "white" => "pumpkin")
    end

  end

end

describe Poovey::Message do

  context "a newly created message" do
    
    subject { Poovey::Message.new("dummy", {"hooray" => "yes"}, "payload") }

    it { should be_frozen }
    
    it "should allow name to be matched" do
      expect(subject.name_matches?("dummy")).to be_true
      expect(subject.name_matches?("dumm")).to  be_false
      expect(subject.name_matches?(/dumm/)).to  be_true
    end

    it "should allow parameters to be matched" do
      expect(subject.parameter_matches?("hooray", "yes")).to be_true
      expect(subject.parameter_matches?("hooray", "y")).to   be_false
      expect(subject.parameter_matches?("hooray", /y/)).to   be_true
      expect(subject.parameter_matches?("duh",  "yes")).to   be_false
    end

    it "should return itself in response to #to_poovey_message" do
      expect(subject.to_poovey_message).to be subject
    end
      
  end

  context "the .from constructor" do

    it "should take a single string argument and use it as the name" do
      msg = Poovey::Message.from "bear"
      expect(msg.name).to eq "bear"
      expect(msg.parameters).to be_empty
    end

    it "should take a string argument and a hash and use it as the name and criteria" do
      msg = Poovey::Message.from "bear", "type" => "grizzly"
      expect(msg.name).to eq "bear"
      expect(msg.parameters).to include("type" => "grizzly")
    end

  end

end

describe Poovey::Criteria do

  context "a newly created criteria object" do
    
    subject { Poovey["hooray"] }
    
    it { should be_frozen }

  end

  let(:no_parameter_message) { Poovey.message "hooray" }
  let(:one_parameter_message) { Poovey.message "hooray", "yay" => "yes" }
  let(:two_parameter_message) { Poovey.message "hooray", "yay" => "yes", "hip" => "hip" }

  context "with just a name" do
    
    subject { Poovey["hooray"] }
    let(:different_name_message) { Poovey.message "boo" }

    it "should match messages with any parameters" do
      expect(subject === no_parameter_message).to   be_true
      expect(subject === one_parameter_message).to  be_true
      expect(subject === two_parameter_message).to  be_true
      expect(subject === different_name_message).to be_false
    end

  end

end

describe Poovey::Exchange

describe Poovey::LinearDispatchBehavior do
  
  let(:dispatcher) { Poovey::SynchronousDispatcher.new behavior: Poovey::LinearDispatchBehavior }
  subject { Poovey::Exchange.new(dispatcher) }
  let(:right) { double "right listener" }
  let(:wrong) { double "wrong listener" }

  it "should dispatch messages to appropriate listeners" do
    right.should_receive(:call)
    wrong.should_not_receive(:call)

    subject.route "vux", wrong
    subject.route "orz", {"not" => "me"}, wrong
    subject.route "orz", {"yes" => "me"}, right

    subject.deliver "orz", "yes" => "me"
  end

  it "should dispatch to the first matching listener added" do
    right.should_receive(:call)
    wrong.should_not_receive(:call)

    subject.route "vux", wrong
    subject.route "orz", right
    subject.route "orz", {"yes" => "me"}, wrong

    subject.deliver "orz", "yes" => "me"
  end

  it "should send unmatched jobs to a fallback listener" do
    right.should_receive(:call)
    wrong.should_not_receive(:call)

    subject.route "vux", wrong
    subject.route "orz", wrong
    dispatcher.fallback_listener = right
    
    subject.deliver "spathi"
  end

end
