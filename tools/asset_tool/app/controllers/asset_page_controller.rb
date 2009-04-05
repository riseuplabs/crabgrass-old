class AssetPageController < BasePageController
  before_filter :fetch_asset
#  javascript :extra
  stylesheet 'asset'

  include AssetPageHelper

  def show
    redirect_to page_url(@page, :action => 'error') unless @asset
  end

  def create
    @page_class = AssetPage
    if params[:cancel]
      return redirect_to(create_page_url(nil, :group => params[:group]))
    elsif request.post?      
        return flash_message_now :error => "No data uploaded" unless params[:asset][:uploaded_data].any?
        begin
        # create asset
        @asset = Asset.make params[:asset]
        unless @asset.valid?
          flash_message_now :object => @asset
          return
        end
        
        params[:page][:title] = @asset.basename unless params[:page][:title].any?
        @page = @page_class.create!(params[:page].merge(
          :user => current_user,
          :share_with => params[:recipients],
          :access => params[:access],
          :data => @asset
        ))  
        redirect_to(page_url(@page))
      rescue Exception => exc
        @page = exc.record
        flash_message_now :exception => exc
      end
    end
  end

  def update
    @asset.update_attributes params[:asset]
    if @asset.valid?
      current_user.updated(@page)
      redirect_to(page_url(@page))
    else
      flash_message_now :object => @page
    end
  end

  def destroy_version
    asset_version = @page.data.versions.find_by_version(params[:id])
    asset_version.destroy
    respond_to do |format|
      format.html do
        message(:success => "file version deleted".t)
        redirect_to(page_url(@page))
      end
      format.js do
        render(:update) {|page| page.hide "asset_#{asset_version.asset_id}_version_#{asset_version.version}"}
      end
    end
  end

  # xhr request
  def generate_preview
    @asset.generate_thumbnails
    render :update do |page|
      page.replace_html 'preview_area', asset_link_with_preview(@asset)
    end
  end
  
  # xhr request  
  def add_file_field
    render :update do |page|
      page.insert_html :before, 'add_file_field', render(:partial => 'file_field')
    end
  end

  def regenerate
    @asset.thumbnails.each do |tn|
      tn.generate(true)
    end
    @asset.versions.latest.clone_files_from(@asset)
    redirect_to page_url(@page, :action => 'show')
  end

  # temp code, probably will be replaced by something else later.
  def add_to_gallery
    gallery = Gallery.find_by_id(params[:gallery_id])
    if gallery
      current_user.may!(:edit,gallery)
      gallery.add_image!(@asset)
    end
    redirect_to page_url(@page)
  rescue Exception => exc
    flash_message_now :exception => exc
  end

  protected
  
  def authorized?
    if @page.nil?
      true
    elsif action?(:update, :add_to_gallery)
      current_user.may?(:edit,@page)
    elsif action?(:generate_preview, :show)
      @page.public? or current_user.may?(:view,@page)
    else
      current_user.may?(:admin, @page)
    end  
  end
 
  def fetch_asset
    @asset = @page.data if @page
  end
  
  def setup_view
    @show_attach = false
    @show_posts = true
  end
  
end
