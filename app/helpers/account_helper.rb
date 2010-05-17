module AccountHelper
  def signup_url
    current_site.signup_redirect_url ||
      url_for :controller => '/account',
        :action => 'signup',
        :redirect => params[:redirect]
  end
end
