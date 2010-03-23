class Me::MessagesController < Me::BaseController
  protected
  def authorized?
    redirect_to me_path
  end
end
