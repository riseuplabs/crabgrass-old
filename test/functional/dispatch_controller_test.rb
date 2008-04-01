require File.dirname(__FILE__) + '/../test_helper'
require 'dispatch_controller'

# Re-raise errors caught by the controller.
class DispatchController; def rescue_action(e) raise e end; end

class DispatchControllerTest < Test::Unit::TestCase

  fixtures :pages

  def setup
    @controller = DispatchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  #really more like a unit test
  def test_find_controller_with_space_and_page_id
    get :dispatch, :_page => 'garble 5'
    assert assigns(:page)
    assert assigns(:page).is_a?(Tool::Discussion)
  end

  def test_find_controller_with_plus_and_page_id
    get :dispatch, :_page => 'garble+5'
    assert assigns(:page)
    assert assigns(:page).is_a?(Tool::Discussion)
  end
end
