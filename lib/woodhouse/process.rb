# TODO: take arguments. Also consider using thor.
class Woodhouse::Process

  def initialize(keyw = {})
    @server = keyw[:server] || build_default_server(keyw)
  end
  
  def execute
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
      @server.wait(:shutdown) 
    rescue Interrupt
      puts "Shutting down."
      @server.shutdown!
      @server.wait(:shutdown)
    ensure
      @server.terminate
      exit
    end
  end

  private

  def build_default_server(keyw)
    Woodhouse::Server.new(
      :layout => keyw[:layout] || Woodhouse.global_layout,
      :node   => keyw[:node]   || :default
    )
  end

end
