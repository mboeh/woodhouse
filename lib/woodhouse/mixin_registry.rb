class Woodhouse::MixinRegistry < Woodhouse::Registry 

  class << self
    
    def classes
      @classes ||= {}
    end

    def register(klass)
      classes[klass.name.to_sym] = klass
    end

  end
  
  def [](worker)
    Woodhouse::MixinRegistry.classes[worker]
  end

  def each(&blk)
    Woodhouse::MixinRegistry.each &blk
  end

end
