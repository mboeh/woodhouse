require 'mongo'

class Workling::JobLoggers::MongoLog

  attr_reader :collection

  def initialize(collection_name = 'workling_jobs')
    @collection ||= begin
      configuration
      cx = Mongo::Connection.new(configuration['host'], configuration['port'])
      db = cx.db(configuration['database'])
      if configuration['username']
        db.authenticate(configuration['username'], configuration['password'])
      end
      db.collection(collection_name)
    end
  end

  def log(job_ident, status, metadata)
    metadata = metadata.dup
    metadata.delete :_exception
    @collection.update({ "_id" => job_ident }, {
                         "$push" => { 
                            "activity" => {
                              status => true,
                              "time" => Time.now,
                              "args"   => metadata,
                             }
                          }
                     }, :upsert => true)
  end

  private

    def configuration
      @configuration ||= begin
        YAML.load(File.read(RAILS_ROOT + "/config/mongo.yml"))[Rails.env]
      end
    end

end
