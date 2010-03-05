require File.dirname(__FILE__) + '/../../../../test/test_helper'
require 'info_page_controller'

# Re-raise errors caught by the controller.
class InfoPageController; def rescue_action(e) raise e end; end

class InfoPageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations

  def setup
    @controller = InfoPageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    #TODO: figure out what this controller does and write a test for it
  end

end
