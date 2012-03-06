#
#  Discovery is responsible for loading workers in app/workers. 
#
module Ganymede
  class Discovery
    cattr_accessor :discovered
    @@discovered = []
    
    # requires worklings so that they are added to routing. 
    def self.discover!
      Dir.glob(Ganymede.load_path.map { |p| "#{ p }/**/*.rb" }).each { |wling| require wling }
    end
  end
end
