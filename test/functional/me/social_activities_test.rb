require File.dirname(__FILE__) + '/../../test_helper'

class Me::SocialActivitiesControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships

  def test_index_html
    blue = users(:blue)
    make_activities_for_blue_friends
    login_as :blue
    get :index
    activities = assigns(:activities)
    assert activities.count > 0
  end

  def test_index_xhr
    xhr :get, :index
    assert_response(:success)
    assert assigns(:activities_drop)
  end

  protected

  def make_activities_for_blue_friends
    public_group = groups(:public_group)
    red = users(:red)
   
    public_group.add_user!(red)
  end

end
