class Admin::UsersControllerTest < ActionController::TestCase
  def setup
    @controller = Admin::UsersController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
end
