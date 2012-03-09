class Ganymede::Registry
  include Ganymede::Util
  include Celluloid

  def [](worker)
    raise NotImplementedError, "subclass Ganymede::Registry and override #[]"
  end
end
