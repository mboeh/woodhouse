class Woodhouse::Runners::DummyRunner < Woodhouse::Runner

  def subscribe
    wait :spin_down
  end

  def spin_down
    signal :spin_down
  end

end
