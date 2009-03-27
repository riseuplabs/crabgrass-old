require File.dirname(__FILE__) + '/../../test_helper'
require 'message_page_controller'

# Re-raise errors caught by the controller.
class MessagePageController; def rescue_action(e) raise e end; end

class Tool::MessagePageControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations

  def setup
    @controller = MessagePageController.new
    @request    = ActionController::TestRequest.new
    @request.host = "localhost"
    @response   = ActionController::TestResponse.new
  end

  def test_create_and_show
    login_as :orange
    
    assert_no_difference 'Page.count' do
      get :create, :id => MessagePage.class_display_name
      assert_response :success
#      assert_template 'message_page/create'
    end
  
    assert_difference 'MessagePage.count' do
      post :create, :id => MessagePage.class_display_name, :title => 'test title', :to => 'red', :message => 'hey d00d'
      assert_response :redirect
    end
    
    p = Page.find(:all)[-1] # most recently created page (?)
    get :show, :page_id => p.id
    assert_response :success
#    assert_template 'message_page/show'
  end
end
