# Implements a very basic registry for Woodhouse extensions. This is a Class
# rather than a Module because it will eventually be used to provide a more
# structured approach than the one Woodhouse::Progress uses.
class Woodhouse::Extension
  
  class << self

    attr_accessor :registry

    def register(name, extension)
      registry[name] = extension
    end

    def install_extension(name, configuration, opts = {}, &blk)
      if ext = registry[name]
        ext.install_extension(configuration, opts, &blk)
      else
        ext = load_extension(name)
        ext.install_extension(configuration, opts, &blk)
      end
    end

    def load_extension(name)
      require "woodhouse/extensions/#{name}"
      registry[name]
    end

  end

  self.registry = {}

end
