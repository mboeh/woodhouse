class Woodhouse::NodeConfiguration < 
  Struct.new(:registry, :server_info, :worker_type, :dispatcher, :logger)

  def initialize(*)
    super
    yield self if block_given?
  end

  # TODO: don't like this.
  def make_dispatcher
    dispatcher.new(self)
  end

end
