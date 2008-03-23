require File.dirname(__FILE__) + '/../../test_helper'
#require 'tool/base_controller'

# Re-raise errors caught by the controller.
class Tool::BaseController; def rescue_action(e) raise e end; end

class Tool::BaseControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations

  def setup
    @controller = Tool::BaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_set_title
    login_as(:orange)
    post :title, :page_id => 1, :page => {:title => "new title"}
    assert_equal "new title", Page.find(1).title
  end

  def test_set_summary_ajax
    login_as :orange
    xhr :post, :summary, :page_id => 1, :page => {:summary => "new summary"}    
    assert_equal "new summary", Page.find(1).summary
  end

#  def test_set_summary_without_ajax
#    login_as :orange
#    post :summary, :page_id => 1, :page => {:summary => "new summary"}    
#    assert_equal "new summary", Page.find(1).summary
#  end
end
