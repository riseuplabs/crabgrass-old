class GalleryController < BasePageController
  
  stylesheet 'gallery'
  
  include GalleryHelper
  include ActionView::Helpers::JavascriptHelper
  

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
  
  def download_gallery
    filename = "/tmp/#{@page.title.gsub(/\s/,'-')}_#{Time.now.to_i}.zip"
    Zip::ZipFile.open(filename, Zip::ZipFile::CREATE) { |zip|
      @page.images.each do |image|
        # multiple images could have the same name
        image_filename = image.filename
        extension = image_filename.split('.').last
        image_name = image_filename[0..(image_filename.size-extension.length-2)]+"_#{image.id}.#{extension}"
        
        zip.get_output_stream(image_name) { |f|
          f.write File.read(image.private_filename)
        }
      end
    }
    send_file(filename)
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
    @page.add_image!(asset,params[:position])
    if request.xhr?
      render :layout => false
    else
      redirect_to page_url(@page)
    end
  #rescue Exception => exc
  #  flash_message_now :exception => exc
  end

  def remove
    asset = Asset.find(params[:id])
    @page.remove_image!(asset)
    if request.xhr?
      undo_link = undo_remove_link(params[:id], params[:position])
      js = javascript_tag("remove_image(#{params[:id]});")
      render(:text => "Successfully removed image! (#{undo_link}) #{js}", :layout => false)
    else
      redirect_to page_url(@page)
    end
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

