require File.dirname(__FILE__) + '/../../test_helper'

class UserTest < ActiveSupport::TestCase

  fixtures :users, :sites, :memberships, :groups

  def setup
  end

  def teardown
    disable_site_testing
  end

  def test_sites
    user = users(:blue)

    assert_equal true, user.all_groups.any?
    assert_equal [1,1,2,2,2], user.all_groups.collect{|g|g.site_id}.compact.sort

    site = sites(:limited)
    groups(:true_levellers).update_attribute(:site_id, site.id)

    assert_equal [1,1,2,2,2, site.id], user.all_groups(true).collect{|g|g.site_id}.compact.sort

    enable_site_testing(:limited)
    assert_equal [site.id], user.all_groups(true).collect{|g|g.site_id}.compact.sort
  end

  protected

end
