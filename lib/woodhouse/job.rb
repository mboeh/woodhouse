require 'securerandom'
require 'forwardable'

class Woodhouse::Job
  attr_accessor :worker_class_name, :job_method, :arguments, :payload
  extend Forwardable

  def_delegators :arguments, :each

  def initialize(class_name = nil, method = nil, args = nil)
    self.worker_class_name = class_name
    self.job_method = method
    self.arguments = args
    unless arguments["_id"]
      arguments["_id"] = generate_id
    end
    if arguments["payload"]
      self.payload = arguments.delete("payload")
    end
    yield self if block_given?
  end

  def job_id
    arguments["_id"]
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

  def [](key)
    arguments[key.to_s]
  end

  def maybe(meth, *args, &blk)
    if respond_to?(meth)
      send(meth, *args, &blk)
    end
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
  
  def generate_id
    SecureRandom.hex(16)
  end

  def payload
    @payload || " "
  end

end
