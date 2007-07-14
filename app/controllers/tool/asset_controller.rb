class Tool::AssetController < Tool::BaseController
  before_filter :fetch_asset

  def show
  end

  # note, massive duplication both here and in the view
  def create
    @page_class = Tool::Asset
    if request.post?
      @page = build_new_page
      @asset = Asset.new params[:asset]
      @page.data = @asset
      if @page.title.any?
        @asset.filename = @page.title + @asset.suffix
      else
        @page.title = @asset.filename
      end
      if @page.save
        return redirect_to page_url(@page)
      else
        message :object => @page
      end
    end
  end

  def update
    @page.data.uploaded_data = params[:asset]
    if @page.data.save
      return redirect_to page_url(@page)
    else
      message :object => @page
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
