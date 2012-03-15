# TODO: take arguments. Also consider using thor.
class Woodhouse::Process
  
  def execute
    @server = Woodhouse::Server.new
    @server.layout = Woodhouse.global_layout
    @server.node = :default
    
    # Borrowed this from sidekiq. https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/cli.rb
    trap "INT" do
      Thread.main.raise Interrupt
    end

    trap "TERM" do
      Thread.main.raise Interrupt
    end

    begin
      @server.start!
      puts "Woodhouse serving as of #{Time.now}. Ctrl-C to stop."
      sleep
    rescue Interrupt
      puts "Shutting down."
      server.shutdown!
      server.wait(:shutdown)
    end
  end

end
