# 
# This is an unnecessary class that allows us to see what is
# being loaded when.
#
# I found this useful and interesting for understanding the
# order of initialization.
#
# Rails::Initializer is defined in 
# /var/lib/gems/1.8/gems/rails-x/lib/initializer.rb
#

class Crabgrass::Initializer < Rails::Initializer

  def load_environment
    info 'LOAD ENVIRONMENT'
    super
  end

  def load_gems
    info 'LOAD GEMS'
    super
  end

  def load_plugins
    info 'LOAD PLUGINS'
    super
  end

  def load_application_initializers
    info 'LOAD INITIALIZERS'
    super
  end

  def load_view_paths
    info 'LOAD VIEW PATHS'
    super
  end

  def load_application_classes
    info 'LOAD APPLICATION CLASSES'
    super
  end

  def disable_dependency_loading
    info 'DONE LOADING'
    super
  end
end

