class GalleryController < BasePageController
  permissions 'collection'

  def show
    params[:page] ||= 1
    @images = @page.children.paginate(:page => params[:page], :per_page => 16)
  end

  def add
    if request.get?
      ids = existing_asset_ids(@page)
      @assets = Asset.visible_to(current_user, @page.group).exclude_ids(ids).media_type(:image).most_recent.paginate(:page => params[:page])

    elsif request.post?
      asset = Asset.find(params[:id])

      # sanity check permissions
      current_user.may!(:view,asset.page)
      @page.group.may!(:view,asset.page) if @page.group

      # add the asset
      @page.add_child!(asset)
      redirect_to page_url(@page)
    end
  rescue Exception => exc
    flash_message_now :exception => exc
  end

  def remove
    asset = Asset.find(params[:id])
    @page.remove_child!(asset)
    redirect_to page_url(@page)
  end

  protected
 
  def existing_asset_ids(page)
    page.children.collect do |child|
      if child.is_a? Asset
        child.id
      elsif child.is_a? Page
        page.data_id
      end
    end
  end

end
