require File.dirname(__FILE__) + '/../../test_helper'
require 'tool/message_controller'

# Re-raise errors caught by the controller.
class Tool::MessageController; def rescue_action(e) raise e end; end

class Tool::MessageControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations

  def setup
    @controller = Tool::MessageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create_and_show
    login_as :orange
    
    assert_no_difference 'Page.count' do
      get :create, :id => Tool::Message.class_display_name
      assert_template 'tool/message/create'
    end
  
    assert_difference 'Tool::Message.count' do
      post :create, :id => Tool::Message.class_display_name, :title => 'test title', :to => 'red', :message => 'hey d00d'
      assert_response :redirect
    end
    
    p = Page.find(:all)[-1] # most recently created page (?)
    get :show, :page_id => p.id
    assert_response :success
    assert_template 'tool/message/show'
  end
end
