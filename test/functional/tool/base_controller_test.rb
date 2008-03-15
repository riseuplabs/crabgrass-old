require File.dirname(__FILE__) + '/../../test_helper'
require 'tool/base_controller'

# Re-raise errors caught by the controller.
class Tool::BaseController; def rescue_action(e) raise e end; end

class Tool::BaseControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :user_participations

  def setup
    @controller = Tool::BaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_set_summary
    login_as :quentin
    # there is something wrong with the following line...
    xhr :post, :summary, :page_id => 1, :summary => "new summary"
    
    assert_equal Page.find(1).summary, "new summary"
  end
end
