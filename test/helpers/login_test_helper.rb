module LoginTestHelper
  def login_as(user)
    user = case user
      when Symbol then users(user)
      when User   then user
      else             nil
    end
    # we set all three by hand so they also work for mocks.
    # otherwise current_user would set them from load_user which loads
    # from the database and thus breaks user mocks
    @controller.stubs(:current_user).returns(user)
    User.current=user
    @request.session[:user] = user
  end

  # the normal acts_as_authenticated 'login_as' does not work for integration tests
  def login(user)
    post '/account/login', {:login => user.to_s, :password => user.to_s}
  end
end
