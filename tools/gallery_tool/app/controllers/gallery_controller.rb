class GalleryController < BasePageController
  
  stylesheet 'gallery'

  verify :method => :post, :only => [:add, :remove]
  
  before_filter :setup_gallery_view

  def show
    params[:page] ||= 1
    @images = @page.images.paginate(:page => params[:page], :per_page => 16)
  end
  
  def detail_view
    @image = @page.images.find(params[:id] || :first)
    @image_index = @page.images.index(@image)
    @next = @page.images[@image_index+1]
    if @page.images.index(@image)-1 >= 0
      @previous = @page.images[@image_index-1]
    end
  end
  
  def edit
    @javascript = :extra
    params[:page] ||= 1
    @images = @page.images.paginate(:page => params[:page], :per_page => 16)
  end
  
  def update
  end

  def find
    existing_ids = @page.image_ids
    # this call doesn't return anything as Asset.visible_to isn't working.
    # see my comment in app/models/asset.rb for details.
    #   @images = Asset.visible_to(current_user, @page.group).exclude_ids(existing_ids).media_type(:image).most_recent.paginate(:page => params[:page])
    results = Asset.media_type(:image).exclude_ids(existing_ids).most_recent.select { |a|
        current_user.may?(:view, a.page) ? a : nil
    }
    current_page = (params[:page] or 1)
    per_page = 30
    @images = WillPaginate::Collection.create(current_page,
                                              per_page,
                                              results.size) do |pager|
      start = (current_page-1)*per_page
      result_slice = (results.to_array[start, per_page] rescue
                      results[start, per_page])
      pager.replace(results[start, per_page])
    end
  rescue => exc
    flash_message :exception => exc
    redirect_to :action => 'show', :page_id => @page.id
  end
  
  def upload
  end
  
  def update_order
    text =""
    ActiveSupport::JSON::decode(params[:images]).each do |image|
      showing = @page.showings.find_by_asset_id(image['id'].to_i)
      text << "#{showing.asset_id}: #{showing.position}"
      showing.insert_at(image['position'].to_i)
      text << "-> #{image['position']}\n"
    end
    render :text => "Saved new order. #{text}", :layout => false
  rescue => exc
    render :text => "Error saving new order: #{exc.message}"
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
  
  def setup_gallery_view
    @image_count = @page.images.size if @page
  end

end

