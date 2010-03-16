if RAILS_ENV == "development"
class DebugController < ApplicationController
  # make the user assume the identity of another user
  def become
    @user = User.find_by_login(params[:id])
    session[:user] = @user.id
    redirect_to (params[:url] || "/")
  end

  def authorized?
    RAILS_ENV == "development"
  end
end
end