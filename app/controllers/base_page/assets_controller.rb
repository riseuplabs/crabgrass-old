
class BasePage::AssetsController < ApplicationController

  before_filter :login_required
  helper 'base_page', 'base_page/assets'
  permissions 'base_page/assets'

  def show_popup
  end

  def close
    render :template => 'base_page/reset_sidebar'
  end

  ## TODO: notify page watcher that an attachment has been added?
  def create
    @asset = Asset.build params[:asset]
    @asset.parent_page = @page
    @asset.filename = params[:asset_title]+@asset.suffix if params[:asset_title].any?
    @asset.save
    flash_message :object => @asset
    redirect_to page_url(@page)
  end

  def destroy
    @asset.destroy
    respond_to do |format|
      format.js {render :nothing => true }
      format.html do
        flash_message(:success => "attachment deleted") 
        redirect_to(page_url(@page))
      end
    end
  end

  protected


  prepend_before_filter :fetch_data
  def fetch_data
    @page = Page.find params[:page_id] if params[:page_id]
    @upart = (@page.participation_for_user(current_user) if logged_in? and @page)
    if @page and params[:id]
      @asset = @page.assets.find_by_id params[:id]
    end
  end


  def authorized?
    may_action?(params[:action], @page)
  end
end
