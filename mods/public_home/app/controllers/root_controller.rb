#
# We also display the site home for people who are NOT logged in.
#
class RootController < ApplicationController
  def index
    if net = current_site.network
      if logged_in? or net.profile.may_see?
        site_home
      else
        login_page
      end
    elsif !logged_in?
      login_page
    else
      redirect_to me_url
    end
  end

end
