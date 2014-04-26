require 'fileutils'

class Woodhouse::Runners::FileRunner < Woodhouse::Runner
  attr_accessor :jobs_dir, :queue_dir

  DEFAULT_QUEUE_DIR = '/tmp/woodhouse/queue'

  def initialize(worker, config)
    super

    server_info = config.server_info || {}
    self.queue_dir = server_info[:path] || DEFAULT_QUEUE_DIR
    self.jobs_dir = "#{queue_dir}/jobs"

    unless File.directory?(jobs_dir) # subdirectory of queue_dir
      config.logger.debug "[Woodhouse initialize] Creating queue directory '#{queue_dir}'"
      FileUtils.mkdir_p jobs_dir
    end
  end

  def subscribe
    until @shutdown do
      service_jobs
      sleep 5
    end
  end

  def spin_down
    @shutdown = true
    signal :spin_down
  end

  def service_jobs
    each_job do |job,queue_id|
      if can_service_job?(job)
        reserve_job(queue_id) { service_job(job) }
      end
    end
  end

  def each_job(&block)
    queue = Dir["#{queue_dir}/j-*"].sort

    queue.each do |job_path|
      job = YAML.load(File.read(job_path))
      queue_id = File.basename(job_path)[2..-1]

      yield(job, queue_id)
    end
  end

  def reserve_job(queue_id, &block)
    enqueued   = "#{queue_dir}/j-#{queue_id}"
    processing = "#{queue_dir}/p-#{queue_id}"
    failed     = "#{queue_dir}/f-#{queue_id}"

    begin
      FileUtils.mv(enqueued, processing)

      if yield
        # Success, clean up
        File.unlink(processing)
      end

    rescue Errno::ENOENT
      # Another worker beat us to the job
      false

    rescue => err
      # Woodhouse internal error occurred during processing
      File.open(processing, 'a') {|f| f.write YAML.dump(err) }
      raise

    ensure
      # If file still hanging around then it failed
      FileUtils.mv(processing, failed) if File.exists?(processing)
    end
  end

end
