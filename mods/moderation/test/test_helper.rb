require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../../test/blueprints')

Engines::Testing.set_fixture_path

def setup_site_with_moderation
    @mod = User.make :login=>"mod"
    @mods = Group.make_owned_by :user=>@mod
    @mods.add_user! @mod
    @site = Site.make :moderation_group => @mods,
      :name => "moderation",
      :domain => "test.host"
    @mods.site = @site
end

#class Test::Unit::TestCase
#  self.use_transactional_fixtures = true
#  self.use_instantiated_fixtures  = false
#  fixtures :all
#end
