require File.dirname(__FILE__) + '/../../test_helper'
require 'tool/discussion_controller'

# Re-raise errors caught by the controller.
class Tool::DiscussionController; def rescue_action(e) raise e end; end

class Tool::DiscussionControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations

  def setup
    @controller = Tool::DiscussionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create_and_show
    login_as :orange
    
    assert_no_difference 'Page.count' do
      get :create, :id => Tool::Discussion.class_display_name
      assert_template 'tool/base/create'
    end
  
    assert_difference 'Tool::Discussion.count' do
      post :create, :id => Tool::Discussion.class_display_name, :page => { :title => 'test discussion' }
      assert_response :redirect
    end
    
    get :show
    assert_response :success
  end

end
