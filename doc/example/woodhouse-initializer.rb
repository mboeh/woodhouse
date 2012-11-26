Woodhouse.configure do |woodhouse|
  woodhouse.runner_middleware << Woodhouse::Middleware::AirbrakeExceptions
end

Woodhouse.layout do |layout|
  layout.node(:default) do |node|
    node.all_workers
    node.remove :ImportWorker
    node.add :ImportWorker, :threads => 2, :only => { :format => "csv" }
    node.add :ImportWorker, :threads => 3, :only => { :format => "xml" }
  end
end
