require File.dirname(__FILE__) + '/../../../test/test_helper'

class ActionController::TestCase

  def assert_site_home
    assert_response :success
    assert_not_nil assigns["current_site"].id
    assert_not_nil assigns["group"]
    assert_template 'root/site_home'
  end

  def assert_login_page
    assert_response :success
    assert_template 'account/index'
  end

  def assert_me_page
    assert_response :redirect
  end
end
