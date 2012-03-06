require 'digest/md5'

module Ganymede
  module Remote
    
    # set the desired runner here. this is initialized with Ganymede.default_runner. 
    mattr_accessor :dispatcher
    
    # set the desired invoker. this class grabs work from the job broker and executes it. 
    mattr_accessor :invoker
    @@invoker ||= Ganymede::Remote::Invokers::ThreadedPoller
    
    # retrieve the dispatcher or instantiate it using the defaults
    def self.dispatcher
      @@dispatcher ||= Ganymede.default_runner
    end
    
    # generates a unique identifier for this particular job. 
    def self.generate_uid(clazz, method)
      uid = ::Digest::MD5.hexdigest("#{ clazz }:#{ method }:#{ rand(1 << 64) }:#{ Time.now }")
      "#{ clazz.to_s.tableize }/#{ method }/#{ uid }".split("/").join(":")
    end
    
    # dispatches to a workling. writes the :uid for this work into the options hash, so make 
    # sure you pass in a hash if you want write to a return store in your workling.
    def self.run(clazz, method, options = {})
      uid = Ganymede::Remote.generate_uid(clazz, method)
      options[:uid] = uid if options.kind_of?(Hash) && !options[:uid]
      Ganymede.find(clazz, method) # this line raises a GanymedeError if the method does not exist. 
      Ganymede.log_job uid, "dispatched", options
      dispatcher.run(clazz, method, options)
      uid
    end
  end
end
