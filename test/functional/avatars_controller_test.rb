require File.dirname(__FILE__) + '/../test_helper'
require 'avatars_controller'

# Re-raise errors caught by the controller.
class AvatarsController; def rescue_action(e) raise e end; end

class AvatarsControllerTest < Test::Unit::TestCase
  def setup
    @controller = AvatarsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
