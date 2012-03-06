require 'workling/remote/invokers/base'

#
#  A basic polling invoker. 
#  
module Ganymede
  module Remote
    module Invokers
      class GanymedeRabbitMQSubscriber < Ganymede::Remote::Invokers::Base
        cattr_accessor :sleep_time
        # 
        #  set up client, sleep time
        #
        def initialize(routing, client_class)
          super
          GanymedeRabbitMQSubscriber.sleep_time = Ganymede.config[:sleep_time] || 0.2
        end
        
        def listen
          @jobthreads = []
          connect do
            routes.each do |queue|
              jobthread = Thread.new do
                client = @client_class.new
                client.connect
                client.subscribe(queue) do |args|
                  run(queue, args)
                  break if Thread.current[:shutdown]
                end
              end
              jobthread.abort_on_exception = true
              @jobthreads << jobthread
            end
          end
          while (!Thread.current[:shutdown]) do
            sleep(self.class.sleep_time)
          end
        end
       
        #
        #  Gracefully stops the Invoker. The currently executing Jobs should be allowed
        #  to finish. 
        #
        def stop
          Thread.current[:shutdown] = true
        end
      end
    end
  end
end
