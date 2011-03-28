#
# We also display the site home for people who are NOT logged in.
#
class RootController < ApplicationController
  def index
    if current_site.network
      site_home
    elsif !logged_in?
      login_page
    else
      redirect_to me_url
    end
  end

end
