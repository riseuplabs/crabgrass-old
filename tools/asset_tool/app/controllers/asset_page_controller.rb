class AssetPageController < BasePageController
  before_filter :fetch_asset
#  javascript :extra
  stylesheet 'asset'

  include AssetPageHelper

  def show
  end

  def create
    @page_class = AssetPage
    @stylesheet = 'page_creation'
    if request.post?
      begin
        # create asset
        @asset = Asset.make params[:asset]
        unless @asset.valid?
          @asset.errors.add('uploaded_data', 'required') unless params[:asset][:uploaded_data].any?
          flash_message_now :object => @asset
          return
        end
        
        # create page
        @page = create_new_page(@page_class)
        @page.data = @asset
        unless @page.title.any?
          @page.title = @asset.basename
        end
        if @page.save
          return redirect_to(page_url(@page))
        end
      rescue Exception => exc
        flash_message_now :exception => exc
      end
    end
  end

  def update
    @asset.update_attributes params[:asset]
#    @asset.filename = @page.title + @asset.suffix
    if @asset.valid?
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
        message(:success => "file version deleted")
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

  def regenerate
    @asset.thumbnails.each do |tn|
      tn.generate(true)
    end
    @asset.versions.latest.clone_files_from(@asset)
    redirect_to page_url(@page, :action => 'show')
  end

  protected
  
  def authorized?
    if @page.nil?
      true
    elsif action?(:update)
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
