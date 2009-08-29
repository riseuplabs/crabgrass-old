require File.dirname(__FILE__) + '/../test_helper'

class StatsControllerTest < ActionController::TestCase
  fixtures :groups, :users, :memberships, :sites

  def setup
  end

  def test_week
    get :week
    assert_response :success
  end

end
