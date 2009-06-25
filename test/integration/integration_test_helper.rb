require "#{File.dirname(__FILE__)}/../test_helper"

class ActionController::IntegrationTest

  # integration test version of login_as
  def login(name = "blue")
    name = name.to_s
    # in Webrat style be case insensitive and reasonably forgiving on the data source
    user = User.find_by_login(name) ||
            User.find_by_login(name.downcase) ||
            User.find_by_name(name) ||
            User.find_by_name(name.downcase)

    unless user.is_a?(UserExtension::AuthenticatedUser)
      raise Webrat::WebratError, "Can't login - no user with name or login '#{name}' found."
    end

    # assume same password as login (since we only store encrypted passwords)
    post 'account/login', {:login => user.login, :password => user.login}
  end
end