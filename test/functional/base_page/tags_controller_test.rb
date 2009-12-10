require File.dirname(__FILE__) + '/../../test_helper'
require 'base_page/tags_controller'

# Re-raise errors caught by the controller.
class BasePage::TagsController; def rescue_action(e) raise e end; end

class BasePage::TagsControllerTest < Test::Unit::TestCase
  fixtures :users, :groups,
           :memberships, :user_participations, :group_participations,
           :pages, :profiles,
           :taggings, :tags

  def setup
    @controller = BasePage::TagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show_popup
    login_as :blue
    get :show, :page_id => 1, :page => "640x480", :position => "60x20"
    assert_response :success
  end

  def test_update
    login_as :blue

    post :update, :page_id => 1, :close => "close"
    assert_response :success

    assert_difference 'Page.find(1).tag_list.length', 2 do
      post :update, :page_id => 1, :add => "tag 1, tag 2"
    end

    assert_difference 'Page.find(1).tag_list.length', -1 do
    post :update, :page_id => 1, :remove => "tag 1"
    end
  end

end
