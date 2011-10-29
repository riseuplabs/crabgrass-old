require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < Test::Unit::TestCase

  def test_defaults_to_conf
    assert_equal Conf.title, Site.new.title
  end

  def test_has_admin_access
    site = Site.new
    council = stub
    site.stubs(:council).returns(council)
    user = mock
    user.expects(:member_of?, council).returns(true)
    assert site.has_access?(:admin, user)
  end

  def test_has_no_admin_access
    site = Site.new
    council = stub
    site.stubs(:council).returns(council)
    user = mock
    user.expects(:member_of?, council).returns(false)
    assert !site.has_access?(:admin, user)
  end

end
