require File.dirname(__FILE__) + '/../../test_helper'

class Admin::BaseControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships

  def setup
    enable_site_testing
  end

  def test_get_index
    login_as :blue
    get :index
    assert_response :success
  end
end
