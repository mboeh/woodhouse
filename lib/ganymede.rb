module Ganymede
  class GanymedeError < StandardError; end
  class GanymedeNotFoundError < GanymedeError; end
  class GanymedeConnectionError < GanymedeError; end
  class GanymedeConfigurationError < GanymedeError; end
  
  VERSION = "0.5.0"
end
