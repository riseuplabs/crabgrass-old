require File.dirname(__FILE__) + '/../../test_helper'

class Admin::AccountControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships

  def setup
    enable_site_testing
  end

  def test_become
    login_as :blue
    blue = users(:blue)
    red = users(:red)
    get :become, :id => red.id
    assert_response :redirect
    assert_redirected_to '/'
    assert_equal red.id, session[:user],
      "session[:user] should be set to impersonated users id."
    assert_equal blue.id, session[:admin],
      "session[:admin] should be set to admins user id."
  end
end
