require 'workling/remote/invokers/base'

#
#  A threaded polling Invoker. 
# 
#  TODO: refactor this to make use of the base class. 
# 
module Woodhouse
  module Remote
    module Invokers
      class ThreadedPoller < Woodhouse::Remote::Invokers::Base
        
        cattr_accessor :sleep_time, :reset_time
      
        def initialize(routing, client_class)
          super
          
          ThreadedPoller.sleep_time = Woodhouse.config[:sleep_time] || 2
          ThreadedPoller.reset_time = Woodhouse.config[:reset_time] || 30
          
          @workers = ThreadGroup.new
          @mutex = Mutex.new
        end      
          
        def listen                
          # Allow concurrency for our tasks
          ActiveRecord::Base.allow_concurrency = true

          # Create a thread for each worker.
          Woodhouse::Discovery.discovered.each do |clazz|
            puts("Discovered listener #{clazz}")
            thread = Thread.new(clazz) { |c| clazz_listen(c) }
            @workers.add(thread)
          end
         
          @started = true
 
          # Wait for all workers to complete
          catch :gobyenow do
            loop do
              @workers.list.each { |t| 
                if t.join(1)
                  puts "A thread died. Shutting down."
                  stop
                  throw :gobyenow
                end
              }
            end
          end

          puts "Joining all threads."
          @workers.list.each { |t| t.join }

          puts "Reaped listener threads. "
        
          # Clean up all the connections.
          ActiveRecord::Base.verify_active_connections!
          puts "Cleaned up connection: out!"
        end
      
        # Check if all Worker threads have been started. 
        def started?
          @started
        end
        
        # number of worker threads running
        def worker_threads
          @workers.list.size
        end
      
        # Gracefully stop processing
        def stop
          puts "stopping threaded poller..."
          sleep 1 until started? # give it a chance to start up before shutting down. 
          puts "Giving Listener Threads a chance to shut down. This may take a while... "
          @workers.list.each { |w| w[:shutdown] = true }
          puts "Listener threads were shut down."
        end

        # Listen for one worker class
        def clazz_listen(clazz)
          puts("Listener thread #{clazz.name} started")
           
          # Read thread configuration if available
          if Woodhouse.config.has_key?(:listeners)
            if Woodhouse.config[:listeners].has_key?(clazz.to_s)
              config = Woodhouse.config[:listeners][clazz.to_s].symbolize_keys
              thread_sleep_time = config[:sleep_time] if config.has_key?(:sleep_time)
            end
          end

          hread_sleep_time ||= self.class.sleep_time
                
          # Setup connection to client (one per thread)
          connection = @client_class.new
          connection.connect
          puts("** Starting client #{ connection.class } for #{clazz.name} queue")
     
          # Start dispatching those messages
          while (!Thread.current[:shutdown]) do
            begin
            
              # Thanks for this Brent! 
              #
              #     ...Just a heads up, due to how rails’ MySQL adapter handles this  
              #     call ‘ActiveRecord::Base.connection.active?’, you’ll need 
              #     to wrap the code that checks for a connection in in a mutex.
              #
              #     ....I noticed this while working with a multi-core machine that 
              #     was spawning multiple workling threads. Some of my workling 
              #     threads would hit serious issues at this block of code without 
              #     the mutex.            
              #
              @mutex.synchronize do 
                unless ActiveRecord::Base.connection.active?  # Keep MySQL connection alive
                  unless ActiveRecord::Base.connection.reconnect!
                    logger.fatal("Failed - Database not available!")
                    break
                  end
                end
              end

              # Dispatch and process the messages
              n = dispatch!(connection, clazz)
              puts("Listener thread #{clazz.name} processed #{n.to_s} queue items") if n > 0
              sleep(self.class.sleep_time) unless n > 0
            
              # If there is a memcache error, hang for a bit to give it a chance to fire up again
              # and reset the connection.
              rescue Woodhouse::WoodhouseConnectionError
                logger.warn("Listener thread #{clazz.name} failed to connect. Resetting connection.")
                sleep(self.class.reset_time)
                connection.reset
            end
          end
        
          begin
            puts("Listener thread #{clazz.name} ended")
          rescue Errno::EBADF
            # Logger already closed
          end
        end
      
        # Dispatcher for one worker class. Will throw MemCacheError if unable to connect.
        # Returns the number of worker methods called
        def dispatch!(connection, clazz)
          n = 0
          for queue in @routing.queue_names_routing_class(clazz)
            begin
              result = connection.retrieve(queue)
              if result
                n += 1
                handler = @routing[queue]
                method_name = @routing.method_name(queue)
                puts("Calling #{handler.class.to_s}\##{method_name}(#{result.inspect})")
                handler.dispatch_to_worker_method(method_name, result)
              end
            rescue MemCache::MemCacheError => e
              puts("FAILED to connect with queue #{ queue }: #{ e } }")
              raise e
            end
          end
        
          return n
        end
      end
    end
  end
end
