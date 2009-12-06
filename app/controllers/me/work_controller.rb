class Me::WorkController < Me::BaseController

  def show
    path = parse_filter_path("/work/#{current_user.id}")
    @pages = Page.paginate_by_path(path, options_for_me(:page => params[:page]))
    handle_rss(
      :title => current_user.name + ' ' + I18n.t(:me_work_link),
      :link => me_work_path,
      :image => avatar_url(:id => @user.avatar_id||0, :size => 'huge')
    )
  end

  protected

  def context
    super
    add_context I18n.t(:me_work_link), url_for(:controller => '/me/work', :action => params[:action], :path => params[:path])
  end

end
