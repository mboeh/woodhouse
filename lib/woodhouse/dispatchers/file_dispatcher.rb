require 'fileutils'

class Woodhouse::Dispatchers::FileDispatcher < Woodhouse::Dispatcher
  attr_accessor :jobs_dir, :queue_dir

  DEFAULT_QUEUE_DIR = '/tmp/woodhouse/queue'

  def initialize(config, opts = {}, &blk)
    super

    server_info = @config.server_info || {}
    self.queue_dir = server_info[:path] || DEFAULT_QUEUE_DIR
    self.jobs_dir = "#{queue_dir}/jobs"

    unless File.directory?(jobs_dir) # subdirectory of queue_dir
      @config.logger.debug "[Woodhouse initialize] Creating queue directory '#{queue_dir}'"
      FileUtils.mkdir_p jobs_dir
    end
  end


  private

  def deliver_job(job)
    filename = "#{jobs_dir}/#{job.job_id}"
    payload = YAML.dump(job)

    @config.logger.debug "[Woodhouse] Writing job #{job.exchange_name} to #{filename}"
    File.open(filename, 'w') {|f| f.write(YAML.dump(job)) }

    enqueue(filename)
  end

  def deliver_job_update(job, data)
    @config.logger.info "[Woodhouse job update] #{job.job_id} -- #{data.inspect}"
  end

  def enqueue(job_filename)
    enqueued_filename = Dir["#{queue_dir}/j-*"].max || "#{queue_dir}/j-00000000"
    10.times do
      begin
        enqueued_filename.succ!
        File.symlink(job_filename, enqueued_filename)
        break
      rescue Errno::EEXIST
        # Another dispatcher beat us to this position, try again
      end

      raise "Woodhouse FileDispatcher is not designed for high load scenarios. " +
        "Maybe you should be using the AMQP dispatcher instead?"
    end

    enqueued_filename
  end

end
