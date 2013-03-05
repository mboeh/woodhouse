class Woodhouse::MixinRegistry < Woodhouse::Registry 

  class << self
    
    def classes
      @classes ||= {}
    end

    def register(klass)
      register_worker klass.name, klass
    end

    def register_worker(class_name, klass)
      classes[class_name.to_s] = klass
    end

  end
  
  def [](worker)
    Woodhouse::MixinRegistry.classes[worker.to_s]
  end

  def each(&blk)
    Woodhouse::MixinRegistry.classes.each &blk
  end

end
