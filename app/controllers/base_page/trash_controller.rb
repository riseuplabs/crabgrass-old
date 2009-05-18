class BasePage::TrashController < ApplicationController

  before_filter :login_required
  helper 'base_page', 'base_page/trash'

  def show_popup
  end

  def close
    render :template => 'base_page/reset_sidebar'
  end

  def delete
    url = from_url(@page)
    @page.delete
    redirect_to url
  end

  def undelete
    url = page_url(@page)
    @page.undelete
    redirect_to url
  end

  def destroy
    url = from_url(@page)
    @page.destroy
    redirect_to url
  end

  protected

  def authorized?
    current_user.may?(:admin, @page)
  end

  prepend_before_filter :fetch_data
  def fetch_data
    @page = Page.find params[:page_id] if params[:page_id]
    @upart = (@page.participation_for_user(current_user) if logged_in? and @page)
  end
end
