require File.join(File.dirname(__FILE__), 'boot')           # load rails
require File.join(File.dirname(__FILE__), '/../../../rails/boot') # load this plugin


# define some dummy classes and methods used by crabgrass_mods
class Conf
  def self.plugin_enabled?(path)
    true
  end
end
def info(x,y=0)
end

Rails::Initializer.run do |config|
  #config.plugin_paths << "#{File.dirname(__FILE__)}/../../../"

  config.action_controller.session = { :key => "xxxx", :secret => "65d7f157d09d6a6a549cb273c24318330fdb5c565a781cdf406ddfcdbf45b7468c935c6e84d9b5" }
end

