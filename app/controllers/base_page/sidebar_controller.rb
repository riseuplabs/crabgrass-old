class BasePage::SidebarController < ApplicationController
  helper 'base_page'
  permissions 'base_page'

  def refresh
    render :template => 'base_page/reset_sidebar'
  end

  protected

  prepend_before_filter :fetch_page
  def fetch_page
    if params[:page_id]
      @page = Page.find_by_id(params[:page_id])
      @upart = @page.participation_for_user(current_user)
    end
    true
  end

end

