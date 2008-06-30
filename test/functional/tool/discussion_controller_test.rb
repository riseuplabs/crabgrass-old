require File.dirname(__FILE__) + '/../../test_helper'
require 'discussion_page_controller'

# Re-raise errors caught by the controller.
class DiscussionPageController; def rescue_action(e) raise e end; end

class Tool::DiscussionControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations

  def setup
    @controller = DiscussionPageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create_and_show
    login_as :orange
    
    assert_no_difference 'Page.count' do
      get :create, :id => DiscussionPage.class_display_name
      assert_template 'base_page/create'
    end
  
    assert_difference 'DiscussionPage.count' do
      post :create, :id => DiscussionPage.class_display_name, :page => { :title => 'test discussion' }
      assert_response :redirect
    end
    
    get :show
    assert_response :success
  end

end
