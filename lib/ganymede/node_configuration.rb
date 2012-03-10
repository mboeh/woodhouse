class Ganymede::NodeConfiguration < 
  Struct.new(:registry, :server_info, :worker_type)

  def initialize(*)
    super
    yield self if block_given?
  end
  
end
