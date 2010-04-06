module LoginTestHelper
  def login_as(user)
    user = case user
      when Symbol then users(user)
      when User   then user
      else             nil
    end
    @controller.stubs(:current_user).returns(user)
    @request.session[:user] = user
  end

  # the normal acts_as_authenticated 'login_as' does not work for integration tests
  def login(user)
    post '/account/login', {:login => user.to_s, :password => user.to_s}
  end
end