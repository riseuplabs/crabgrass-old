
class BasePage::AssetsController < ApplicationController

  before_filter :login_required
  helper 'base_page', 'base_page/assets'
  permissions 'base_page'

  def show
    if params[:popup]
      render :partial => 'base_page/assets/popup'
    else
      render :nothing => true
    end
  end

  def update
    @page.cover = @asset
    @page.save!
    render :template => 'base_page/reset_sidebar'
  end

  ## TODO: notify page watcher that an attachment has been added?
  ## TODO: use iframe trick to make this ajaxy
  def create
    asset = @page.add_attachment! params[:asset], :cover => params[:use_as_cover], :title => params[:asset_title]
    flash_message :object => asset
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

end
