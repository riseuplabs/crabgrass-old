class Me::PagesController < Me::BaseController

  def show
  end

  def index
    path = parse_filter_path(params[:path])
    @pages = Page.paginate_by_path(path, options_for_me, pagination_params)
  end

end

