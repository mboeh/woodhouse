# TODO: take arguments. Also consider using thor.
class Woodhouse::Process

  def initialize(keyw = {})
    @server = keyw[:server] || build_default_server(keyw)
    self.class.register_instance self
  end

  def self.register_instance(instance)
    @instance = instance
  end

  # Returns the current global Woodhouse process instance, if it is running.
  def self.instance
    @instance
  end

  def execute
    # Borrowed this from sidekiq. https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/cli.rb
    trap "INT" do
      Thread.main.raise Interrupt
    end

    trap "TERM" do
      Thread.main.raise Interrupt
    end

    Woodhouse::Watchdog.start
    Woodhouse::Watchdog.listen do |id, transition|
      Woodhouse.global_configuration.logger.info "[##{id}] #{transition}"
    end

    begin
      @server.start!
      puts "Woodhouse serving as of #{Time.now}. Ctrl-C to stop."
      @server.wait(:shutdown) 
    rescue Interrupt
      shutdown
    ensure
      @server.terminate
      Woodhouse::Watchdog.stop
    end
  end

  def shutdown
    puts "Shutting down."
    @server.shutdown!
    @server.wait(:shutdown)
  end

  private

  def build_default_server(keyw)
    Woodhouse::Server.new(
      :layout => keyw[:layout] || Woodhouse.global_layout,
      :node   => keyw[:node]   || :default
    )
  end

end
