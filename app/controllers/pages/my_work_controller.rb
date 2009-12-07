class Pages::MyWorkController < ApplicationController

  before_filter :login_required

  def show
    path = parse_filter_path("/work/#{current_user.id}")
    @pages = Page.paginate_by_path(path, options_for_me(:page => params[:page]))
    handle_rss(
      :title => current_user.name + ' ' + I18n.t(:my_work_link),
      :link => my_work_path,
      :image => avatar_url(:id => current_user.avatar_id||0, :size => 'huge')
    )
  end

  protected

  def context
    super
    add_context I18n.t(:my_work_link), my_work_url
  end

  def authorized?
    true
  end

end
