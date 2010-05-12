require File.dirname(__FILE__) + '/../../test_helper'

class Me::SocialActivitiesControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships

  def test_index
    blue = users(:blue)
    make_activities_for_blue_friends
    login_as :blue

    get :index
    activities = assigns(:activities)
    assert activities.count > 0

    xhr :get, :index
    activities_drop = assigns(:activities_drop)
    assert (activities_drop.size == 5)

    xhr :get, :index, :see => 'more'
    activities_drop = assigns(:activities_drop)
    assert (activities_drop.size > 5)
  end

  protected

  def make_activities_for_blue_friends
    public_group = groups(:public_group)
    friends = [users(:red), users(:yellow), users(:orange), users(:purple), users(:green), users(:gerrard)]
    friends.each do |friend| 
      public_group.add_user!(friend)
    end
  end

end
