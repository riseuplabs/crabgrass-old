require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../../test/blueprints')

Engines::Testing.set_fixture_path

def setup_site_with_admins
  @admin = User.make :login=>"admin_user"
  @net = Network.make_owned_by :user=>@admin
  @net.add_user! @admin
  @admins = Council.make_for :group=>@net
  @admins.add_user! @admin
  @net.add_committee! @admins, true
  @site = Site.make :network => @net,
    :name => "site_with_admins",
    :domain => "test.host",
    :council => @admins
  @net.site = @site
  @admins.site = @site
  @non_admin = User.make :login=>"non_admin_user"
  @net.add_user! @non_admin
end
