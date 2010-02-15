require File.dirname(__FILE__) + '/../../test_helper'

class GroupTest < ActiveSupport::TestCase

  fixtures :sites, :groups

  def setup
  end

  def teardown
    disable_site_testing
  end

  def test_sites
    filter = "anim%"

    groups = Group.find(:all, :conditions => ["groups.name LIKE ? OR groups.full_name LIKE ?", filter, filter])
    assert_equal groups(:animals), groups.first

    enable_site_testing(:limited)
    groups = Group.find(:all, :conditions => ["groups.name LIKE ? OR groups.full_name LIKE ?", filter, filter])
    assert_nil groups.first

    enable_site_testing(:test)
    groups = Group.find(:all, :conditions => ["groups.name LIKE ? OR groups.full_name LIKE ?", filter, filter])
    assert_equal groups(:animals), groups.first
  end

end

