require 'workling/remote/runners/base'
require 'workling/clients/memcache_queue_client'

#
#  Runs Jobs over a Client. The client should be a subclass of Woodhouse::Client::Base. 
#  Set the client like this: 
#
#      Woodhouse::Remote::Runners::ClientRunner.client = Woodhouse::Clients::AmqpClient.new
#
#  Jobs are dispatched by requesting them on the Client. The Runner takes care of mapping of queue names to worker code. 
#  this is done with Woodhouse::ClassAndMethodRouting, but you can use your own by sublassing Woodhouse::Routing. 
#  Don’t worry about any of this if you’re not dealing directly with the queues.
#
#  There’s a workling-client daemon that uses the configured invoker to retrieve work and dispatching these to the 
#  responsible workers. If you intend to run this on a remote machine, then just check out your rails project 
#  there and start up the workling client like this: ruby script/workling_client run.
#
module Woodhouse
  module Remote
    module Runners
      class ClientRunner < Woodhouse::Remote::Runners::Base
        
        # Routing class. Woodhouse::Routing::ClassAndMethodRouting.new by default. 
        cattr_accessor :routing
        @@routing ||= Woodhouse::Routing::ClassAndMethodRouting.new
        
        # The workling Client class. Woodhouse::Clients::MemcacheQueueClient.new by default. 
        cattr_accessor :client
        @@client ||= Woodhouse::Clients::MemcacheQueueClient.new
        
        # enqueues the job onto the client
        def run(clazz, method, options = {})
          
          # neet to connect in here as opposed to the constructor, since the EM loop is
          # not available there. 
          @connected ||= self.class.client.connect
          
          self.class.client.request(@@routing.queue_for(clazz, method), options)    
          
          return nil
        end
      end
    end
  end
end
