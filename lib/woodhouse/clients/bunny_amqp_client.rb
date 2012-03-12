require 'workling/clients/base'

#
#  An Ampq client
#
module Woodhouse
  module Clients
    class BunnyAmqpClient < Woodhouse::Clients::Base
      
      # starts the client. 
      def connect
        begin
          @bunny = Bunny.new(options)
          @bunny.start
        rescue => err
          Woodhouse.job_logger.log("NONE", "raised exception", :_exception => err)
          raise WoodhouseError.new("Couldn't start bunny amqp client, ensure the AMQP server is running.")
        end
      end
      
      # no need for explicit closing. when the event loop
      # terminates, the connection is closed anyway. 
      def close
        @bunny.stop
        # normal amqp does not require stopping
      end
      
      # subscribe to a queue
      def subscribe(key)
        begin
          @amq ||= begin
            MQ.new AMQP.connect(options)
          end
        rescue
          raise WoodhouseError.new("Couldn't start amqp client, if you are running this a server, ensure the server is evented (can't think why you'd want to though!).")
        end
        @amq.queue(key).subscribe do |data|
          value = YAML.load(data)
          yield value
        end
      end
      
      # request and retrieve work
      def retrieve(key)
        ret = @bunny.queue(key).pop[:payload]
        YAML.load(ret) unless ret == :queue_empty
      end
      def request(key, value)
        data = YAML.dump(value)
        @bunny.queue(key).publish(data)
      end

      private

        def options
          opts = {:connect_timeout => 5}
          [:host, :user, :pass, :vhost].each do |opt|
            opts[opt] = Woodhouse.config[opt] if Woodhouse.config[opt]
          end
          opts
        end

    end
  end
end
