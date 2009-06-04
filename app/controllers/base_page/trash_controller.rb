class BasePage::TrashController < ApplicationController

  before_filter :login_required
  helper 'base_page', 'base_page/trash'

  def show_popup
  end

  def update
    if params[:cancel]
      render :template => 'base_page/reset_sidebar'
    elsif params[:delete]
      if params[:type] == 'move_to_trash'
        move
      elsif params[:type] == 'shred_now'
        shred
      end
    end
  end

  def undelete
    url = page_url(@page)
    @page.undelete
    redirect_to url
  end

#  def delete
#    url = from_url(@page)
#    @page.delete
#    redirect_to url
#  end
#
#
#  def destroy
#    url = from_url(@page)
#    @page.destroy
#    redirect_to url
#  end

  protected

  def authorized?
    current_user.may?(:admin, @page)
  end

  prepend_before_filter :fetch_data
  def fetch_data
    @page = Page.find params[:page_id] if params[:page_id]
  end

  def move
    url = from_url(@page)
    @page.delete
    render :update do |page|
      page.redirect_to url
    end
  end

  def shred
    url = from_url(@page)
    @page.destroy
    render :update do |page|
      page.redirect_to url
    end
  end

end
