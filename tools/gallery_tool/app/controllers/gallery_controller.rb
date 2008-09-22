class GalleryController < BasePageController

  verify :method => :post, :only => [:add, :remove]

  def show
    params[:page] ||= 1
    @images = @page.images.paginate(:page => params[:page], :per_page => 16)
  end

  def find
    existing_ids = @page.image_ids
    @images = Asset.visible_to(current_user, @page.group).exclude_ids(existing_ids).media_type(:image).most_recent.paginate(:page => params[:page])
  end

  def add
    asset = Asset.find(params[:id])
    @page.add_image!(asset)
    redirect_to page_url(@page)
  #rescue Exception => exc
  #  flash_message_now :exception => exc
  end

  def remove
    asset = Asset.find(params[:id])
    @page.remove_image!(asset)
    redirect_to page_url(@page)
  end

  protected
 
  def authorized?
    if @page.nil?
      true
    elsif action?(:add, :remove, :find)
      current_user.may?(:edit,@page)
    elsif action?(:show)
      @page.public? or current_user.may?(:view,@page)
    else
      current_user.may?(:admin, @page)
    end  
  end

end

