class Mods::Plugin < Rails::Plugin

  def initialize(directory)
    super directory
  end

  def define_page_type(type_name, options)
    PageClassRegistrar.add(type_name.to_s, options)
  end

#  def add_to_model(model_name, lambda_block)
#    Mods.add_model_mixin(model_name, lambda_block)
#  end

  def extend_model(model_name, &block)
    Mods.add_model_mixin(model_name.to_s, block)
  end

  # added permissions
  #def app_paths
  #  [ File.join(directory, 'app', 'models'), File.join(directory, 'app', 'helpers'), File.join(directory, 'app', 'permissions'), controller_path, metal_path ]
  #end

  ##
  ## DEPRECATED
  ##

  def load_once=(arg)
  end
  def override_views=(arg)
  end
  def apply_mixin_to_model(arg,arg2)
  end

end


