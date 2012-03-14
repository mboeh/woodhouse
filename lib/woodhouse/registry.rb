class Woodhouse::Registry
  include Woodhouse::Util

  def [](worker)
    raise NotImplementedError, "subclass Woodhouse::Registry and override #[]"
  end

  def each
    raise NotImplementedError, "subclass Woodhouse::Registry and override #each"
  end

end
