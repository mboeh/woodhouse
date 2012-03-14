class Woodhouse::Job <
  Struct.new(:worker_class_name, :job_method, :arguments)

  def job_method=(value)
    super value.to_sym
  end

  def initialize(*)
    super
    yield self if block_given?
  end

  # TODO: copypasted from Woodhouse::Layout::Worker. Fix that
  def exchange_name
    "#{worker_class_name}_#{job_method}".downcase
  end

end
