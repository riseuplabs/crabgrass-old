class BasePage::TagsController < ApplicationController

  before_filter :login_required
  helper 'base_page', 'base_page/tags'

  def show_popup
  end

  def update
    if params[:close]
      render :template => 'base_page/reset_sidebar'
      return
    elsif params[:add]
      @page.tag_list.add(params[:add], :parse => true)
      @page.updated_by = current_user
      @page.save
      render :template => 'base_page/reset_sidebar'
    elsif params[:remove]
      @page.tag_list.remove(params[:remove])
      @page.updated_by = current_user
      @page.save
      render :nothing => true
    end
  end

  protected

  def authorized?
    current_user.may?(:edit, @page)
  end

  prepend_before_filter :fetch_data
  def fetch_data
    @page = Page.find params[:page_id] if params[:page_id]
    @upart = (@page.participation_for_user(current_user) if logged_in? and @page)
  end

end

