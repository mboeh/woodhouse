class Woodhouse::NewRelic::InstrumentationMiddleware < Woodhouse::Middleware
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def call(job, worker)
    perform_action_with_newrelic_trace(:name => job.job_method, :class_name => job.worker_class_name, :params => job.arguments, :category => :task, :path => job.queue_name) do
      yield job, worker
    end
  end

end
