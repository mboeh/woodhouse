class Ganymede::Job <
  Struct.new(:worker_class_name, :job_method, :arguments)

  def initialize(*)
    super
    yield self if block_given?
  end

end
