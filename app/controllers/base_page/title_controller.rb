class BasePage::TitleController < ApplicationController

  before_filter :login_required
  helper 'base_page'
  permissions 'base_page'

  # return the edit title form via rjs
  def edit
    render :template => 'base_page/title/edit_title'
  end

  # TODO: add non-ajax version.
  def update
    if params[:save]
      @old_name = @page.name
      @page.title   = params[:page][:title]
      @page.summary = params[:page][:summary]
      @page.name    = params[:page][:name].to_s.nameize if params[:page][:name].any?
      @page.updated_by = current_user
      @new_name = @page.name
      unless @page.save
        render(:template => 'base_page/title/edit_title') and return
      end
    end
    render :template => 'base_page/title/update_title'
  end

  protected

  prepend_before_filter :fetch_data
  def fetch_data
    @page = Page.find params[:page_id] if params[:page_id]
    @upart = (@page.participation_for_user(current_user) if logged_in? and @page)
  end

end
