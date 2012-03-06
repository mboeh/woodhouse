require 'rabbitmq_client'
require 'workling/clients/base'

module Ganymede
  module Clients
    class GanymedeRabbitMQClient < Ganymede::Clients::Base
      def connect
        @client = RabbitMQClient.new(options)
      end
      
      def close
        @client.disconnect if @client.connected?
      end
      
      def request(queue, value)
        @client.queue(queue).publish(value)
      end
      
      def retrieve(queue)
        @client.queue(queue).retrieve
      end
      
      def subscribe(queue)
        @client.queue(queue).subscribe do |value|
          yield value
        end
      end

      private

        def options
          opts = {}
          mapping = { :user => :username, :pass => :password }
          [:host, :user, :pass, :vhost].each do |opt|
            opts[mapping[opt] || opt] = Ganymede.config[opt] if Ganymede.config[opt]
          end
          opts
        end

    end
  end
end
