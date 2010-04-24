require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
Engines::Testing.set_fixture_path

def setup_site_with_translator
  @translator = User.make :login=>"tran"
  @translators = Group.make_owned_by :user=>@translator
  @translators.add_user! @translator
  @site = Site.make :translation_group => @translators.name,
    :name => "translation",
    :domain => "test.host"
  @translators.site = @site
  enable_site_testing @site.name
end

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  def valid_translation
    { :key => keys(:hello), :language => languages(:en), :user => @translator, :text => "Hey d00d" }
  end

  def valid_key
    { :name => "new_key", :project => projects(:crabgrass) }
  end

end
