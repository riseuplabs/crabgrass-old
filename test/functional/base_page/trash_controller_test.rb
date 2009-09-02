require File.dirname(__FILE__) + '/../../test_helper'
require 'base_page/trash_controller'

# Re-raise errors caught by the controller.
class BasePage::TrashController; def rescue_action(e) raise e end; end

class BasePage::TrashControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
           :memberships, :user_participations, :group_participations,
           :pages, :profiles

  def setup
    @controller = BasePage::TrashController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show_popup
    login_as :blue
    get :show, :page_id => 1, :page => "640x480", :position => "60x20"
    assert_response :success
  end

  def test_destroy_with_login
    login_as :blue

    page = Page.create! :title => 'delete me', :owner => users(:blue), :user => users(:blue)
    page_id = page.id

    assert_no_difference 'Page.count' do
      xhr :post, :update, :delete => true, :type => 'move_to_trash', :page_id => page.id
      assert_equal page.reload.flow, FLOW[:deleted]

      post :undelete, :page_id => page.id
      assert_equal page.reload.flow, nil
    end

    assert_difference 'Page.count', -1 do
      xhr :post, :update, :delete => true, :type => 'shred_now', :page_id => page.id
    end
    assert_raise ActiveRecord::RecordNotFound, "Should not be able to find page after destroying." do
      Page.find(page_id)
    end
  end

end
