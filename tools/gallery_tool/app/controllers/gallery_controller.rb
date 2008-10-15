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
  
  def download
    name_base = @page.title.gsub(/\s/,'-')
    file = (Dir.entries(GALLERY_ZIP_PATH) - %w{. ..}).map { |e|
      (m = e.match(/^#{name_base}_(\d+).zip/)) ? [m[1].to_i, e] : nil
    }.compact.sort { |x,y| x[0] <=> y[0] }.last
    if file && file[0] >= @page.updated_at.to_i
      filepath = "#{GALLERY_ZIP_PATH}/#{file[1]}"
    else
      filepath = "#{GALLERY_ZIP_PATH}/#{name_base}_#{Time.now.to_i}.zip"
      Zip::ZipFile.open(filepath, Zip::ZipFile::CREATE) { |zip|
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
    end
    send_file(filepath)
  end
  
  def update_order
    if params[:images]
    text =""
      ActiveSupport::JSON::decode(params[:images]).each do |image|
        showing = @page.showings.find_by_asset_id(image['id'].to_i)
        showing.insert_at(image['position'].to_i)
      end
    else
      showing = @page.showings.find_by_asset_id(params[:id])
      new_pos = (params[:direction] == 'left') ? showing.position - 1 :
        showing.position + 1
      new_pos = @page.showings.size-1 if new_pos < 0
      new_pos = 0 if new_pos > new_pos.size-1
      showing.insert_at(new_pos)
    end
    if request.xhr?
      render :text => "Order changed."[:order_changed], :layout => false
    else
      flash_message_now "Order changed."[:order_changed]
      redirect_to(:controller => 'gallery',
                  :action => 'edit',
                  :page_id => @page.id)
    end
  rescue => exc
    render :text => "Error saving new order: :error_message"[:error_saving_new_order] %{ :error_message => exc.message}
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

  def create
    @page_class = get_page_type
    if request.post?
      return redirect_to(create_page_url) if params[:cancel]
      begin
        @page = create_new_page!(@page_class)
        params[:assets].each do |file|
          next if file.size == 0 # happens if no file was selected
          asset = Asset.make(:uploaded_data =>  file)
          @page.add_image!(asset)
        end
        return redirect_to create_page_url(AssetPage, :gallery => @page.id) if params[:add_more_files]
        return redirect_to(page_url(@page))
      rescue Exception => exc
        @page = exc.record
        flash_message_now :exception => exc
      end
    end
    @stylesheet = 'page_creation'
    render :template => 'gallery/create'
  end
  
  def upload
    logger.fatal 'go ahead'
    if request.xhr?
      render :layout => false
    elsif request.post?
      params[:assets].each do |file|
        next if file.size == 0
        asset = Asset.make(:uploaded_data => file)
        @page.add_image!(asset)
      end
      redirect_to page_url(@page)
    end
  end

  
  def remove
    asset = Asset.find(params[:id])
    @page.remove_image!(asset)
    if request.xhr?
      undo_link = undo_remove_link(params[:id], params[:position])
      js = javascript_tag("remove_image(#{params[:id]});")
      render(:text => "Successfully removed image! (:undo_link)"[:successfully_removed_image]%{
               :undo_link => undo_link
             } + js,
             :layout => false)
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

