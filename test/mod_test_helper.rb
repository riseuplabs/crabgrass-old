require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ActiveSupport::TestCase

  # Add more helper methods to be used by all mod tests here...


  def mod_disabled?
    !mod_enabled?
  end

  def mod_enabled?
    Conf.enabled_mods.include? mod_name.underscore
  end

  def mod_name
    self.class.name.split('::').first
  end

end
