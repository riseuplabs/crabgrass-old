require File.dirname(__FILE__) + '/../test_helper'

class DiscussionPageControllerTest < ActionController::TestCase
  fixtures :pages, :groups, :users, :memberships, :group_participations, :user_participations, :sites

  def test_non_siteadmin_may_not_notify
    with_site :unlimited do
      login_as :gerrard
      get :show, :page_id => DiscussionPage.first.id
      assert_response :success
      assert_select "li#share_li", nil, "Gerrard should be able to share"
      assert_select "li#notify_li", false, "Gerrard should not be able to notify."
    end
  end

  def test_siteadmin_may_notify
    with_site :unlimited do
      login_as :blue
      get :show, :page_id => DiscussionPage.first.id
      assert_response :success
      assert_select "#share_li", nil, "Blue should be able to share"
      assert_select "#notify_li", nil, "Blue should be able to notify"
    end
  end

end
