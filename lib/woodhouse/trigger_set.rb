class Woodhouse::TriggerSet

  def initialize
    @triggers = {}
  end

  def add(event_name, &blk)
    @triggers[event_name.to_sym] ||= []
    @triggers[event_name.to_sym] << blk
  end


  def trigger(event_name, *args)
    (@triggers[event_name.to_sym] || []).each do |trigger|
      trigger.call(*args)
    end
  end

end
