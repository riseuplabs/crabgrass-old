class Me::TimelinesController < Me::BaseController

  def index
    @pages = current_user.pages.recent_pages
  end

end
