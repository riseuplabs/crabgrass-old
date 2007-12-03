class Tool::AssetController < Tool::BaseController
  before_filter :fetch_asset

  def show
  end

  # note, massive duplication both here and in the view
  def create
    @page_class = Tool::Asset
    if request.post?
      @page = build_new_page(@page_class)
      @asset = Asset.new params[:asset]
      @page.data = @asset
      if @page.title.any?
        @asset.filename = @page.title + @asset.suffix
      else
        @page.title = @asset.basename
      end
      if @page.save
        return redirect_to(page_url(@page))
      else
        message :object => @page
      end
    end
  end

  def update
    @page.data.uploaded_data = params[:asset]
    @page.data.filename = @page.title + @page.data.suffix
    if @page.data.save
      return redirect_to(page_url(@page))
    else
      message :object => @page
    end
  end

  def destroy_version
    asset_version = @page.data.find_version(params[:id])
    asset_version.destroy
    respond_to do |format|
      format.html do
        message(:success => "file version deleted")
        redirect_to(page_url(@page))
      end
      format.js { render(:update) {|page| page.visual_effect :fade, "asset_#{asset_version.asset_id}_version_#{asset_version.version}", :duration => 0.5} }
    end
  end

  protected
  
  def fetch_asset
    @asset = @page.data if @page
  end
  
  def setup_view
    @show_attach = false
    @show_posts = true
  end
  
end
