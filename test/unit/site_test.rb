require File.dirname(__FILE__) + '/../test_helper'

class Site < ActiveRecord::Base
  def self.uncache_default
    @default_size = nil
  end
end

class SiteTest < Test::Unit::TestCase
  fixtures :sites, :users, :groups, :memberships

  def test_defaults_to_conf
    assert_equal Conf.title, Site.new.title
  end

  def test_site_admin
    blue = users(:blue)
    kangaroo = users(:kangaroo)
    site = Site.find_by_name("site1")
    admins = Council.create! :name => 'admins'
    site.network.add_committee!(admins, true)
    admins.add_user! blue
    assert blue.may?(:admin, site), 'blue should have access to the first site.'
  end

  def test_no_site_admin_without_council_membership
    kangaroo = users(:kangaroo)
    site = Site.find_by_name("site1")
    admins = Council.create! :name => 'admins'
    site.network.add_committee!(admins, true)
    site.network.add_user! kangaroo
    assert !kangaroo.may?(:admin, site), 'kangaroo should not have :admin access to the first site.'
  end

end
