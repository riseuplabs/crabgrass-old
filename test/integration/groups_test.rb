require File.dirname(__FILE__) + '/../test_helper'

class GroupsTest < ActionController::IntegrationTest
  fixtures :users, :groups, :memberships

  def test_join_network_we_have_access_to
    login :blue
    get '/fai'
    assert_select('a[href="/groups/memberships/join/fai"]') do 
      assert_select 'a', 'Join Network'
    end

    assert_difference 'Membership.count' do
      post "/groups/memberships/join/fai"
    end
  end

end
