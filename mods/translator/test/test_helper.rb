require File.expand_path(File.dirname(__FILE__) + '/../../../test/mod_test_helper')
Engines::Testing.set_fixture_path

class ActiveSupport::TestCase

  # Add more helper methods to be used by all tests here...
  def valid_translation
    { :key => keys(:hello), :language => languages(:english), :user => users(:abie), :text => "Hey d00d" }
  end

  def valid_key
    { :name => "new_key", :project => projects(:crabgrass) }
  end

end
