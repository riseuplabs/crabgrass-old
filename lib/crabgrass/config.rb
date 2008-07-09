# This class lets you set arbitrary key/value pairs in (presumably)
# environments/*.rb to customize the behavior of the application under
# different deployment scenarios.
#
# for example
# Crabgrass::Config.make_target = 'love'
# Crabgrass::Config.not_make_target = 'war'
#
# and then in the code
# Kernel.system "make", Crabgrass::Config.make_target

require 'active_support'

module Crabgrass
  class Config
    @@settings = {}
    
    def self.method_missing(name, *args)
      key = name.to_s.chomp('=').to_sym
      if name.to_s.ends_with?('=')
        # assignment
        @@settings[key] = *args
      else
        # retrieval
        @@settings[key]
      end
    end
  end
end
