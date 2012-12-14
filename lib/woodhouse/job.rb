class Woodhouse::Job
  attr_accessor :worker_class_name, :job_method, :arguments
  attr_accessor :watchdog

  def initialize(class_name = nil, method = nil, args = nil)
    self.worker_class_name = class_name
    self.job_method = method
    self.arguments = args
    yield self if block_given?
  end

  def self.from_poovey_message(message)
    new(*message.name.gsub(/^Woodhouse:/, '').split("#", 2), message.parameters)
  end

  def to_poovey_message
    Poovey::Message.new("Woodhouse:#{worker_class_name}##{job_method}", arguments)
  end

  def to_hash
    {
      "worker_class_name" => worker_class_name,
      "job_method"        => job_method,
    }.merge(arguments)
  end

  def job_method=(value)
    @job_method = value ? value.to_sym : nil
  end

  def arguments=(h)
    @arguments = (h || {}).inject({}){|args,(k,v)|
      args[k.to_s] = v.to_s
      args
    }
  end

  # TODO: copypasted from Woodhouse::Layout::Worker. Fix that
  def exchange_name
    "#{worker_class_name}_#{job_method}".downcase
  end

  def queue_name
    exchange_name
  end

  def describe
    "#{worker_class_name}##{job_method}(#{arguments.inspect})"
  end

end
