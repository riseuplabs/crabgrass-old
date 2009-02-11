class GalleryController < BasePageController
  
  stylesheet 'gallery'
  javascript :extra, 'page'
  
  include GalleryHelper
  include BasePageHelper
  include ActionView::Helpers::JavascriptHelper


  verify :method => :post, :only => [:add, :remove]

  def show
    params[:page] ||= 1
    @images = @page.images.paginate(:page => params[:page], :per_page => 16)
    #@cover = @page.cover
  end

  def comment_image
    @image = @page.images.find(params[:id])
    @post = Post.build(:page => @image.page,
                       :user => current_user,
                       :body => params[:post][:body])
    current_user.updated(@image.page)
    @post.save!
    redirect_to page_url(@page,
                         :action => 'detail_view',
                         :id => @image.id)
  end
  
  
  def add_star
    @image = @page.images.find(params[:id])
    @image.page.add(current_user, :star => true).save!
    if request.xhr?
      render :text => javascript_tag("$('add_star_link').hide();$('remove_star_link').show();"), :layout => false
    else
      redirect_to page_url(@page, :action => 'detail_view', :id => @image.id)
    end
  end

 
  def remove_star
    @image = @page.images.find(params[:id])
    @image.page.add(current_user, :star => false).save!
    if request.xhr?
      render :text => javascript_tag("$('remove_star_link').hide();$('add_star_link').show();"), :layout => false
    else
      redirect_to page_url(@page, :action => 'detail_view', :id => @image.id)
    end
  end
  
  def detail_view
    @showing = @page.showings.find_by_asset_id(params[:id], :include => 'asset')
    @image = @showing.asset
    @image_index = @showing.position
    @next = @showing.lower_item
    @previous = @showing.higher_item

    # we need to set @upart manually as we are not working on @page
    @upart = @image.page.participation_for_user(current_user)

    # the discussion for the detail view is not the discussion of the gallery,
    # it is attached to the asset's hidden page:
    @discussion = @image.page.discussion rescue nil
    @discussion ||= Discussion.new
    @create_post_url = url_for(:controller => 'gallery', :action => 'comment_image', :id => @image.id)
    load_posts()
  end  
  
  def change_image_title
    if request.post?
      # whoever may edit the gallery, may edit the assets too.
      raise PermissionDenied unless current_user.may?(:edit, @page)
      @image = @page.images.find(params[:id])
      page = @image.page
      page.title = params[:title]
      current_user.updated(page)
      page.save!
      redirect_to page_url(@page, :action => 'detail_view', :id => @image.id)
    end
  end
  
  def slideshow
    if params[:image_id] && params[:image_id] != 0
      showing = @page.showings.find(:first, :conditions => { :asset_id => 
                                      params[:image_id]})
    else
      showing = @page.showings.first
    end
    @image = @page.images.find(showing.asset_id) if showing
    @next_id = @page.showings.find(:first, :conditions => { 
                                     :position => showing.position+1
                                   }, :select => 'asset_id').asset_id rescue nil
    if request.xhr?
      render :layout => false
    else
      render :layout => 'gallery_slideshow'
    end
  end
  
  def edit
    params[:page] ||= 1
    @images = @page.images.paginate(:page => params[:page], :per_page => 16)
  end
  
  def make_cover
    unless current_user.may?(:admin, @page)
      if request.xhr?
        render(:text => "You are not allowed to do that!"[:you_are_not_allowed_to_do_that],
               :layout => false) and return
      else
        raise PermissionDenied
      end
    end
    @page.cover = params[:id]
    current_user.updated(@page)
    if request.xhr?
      render :text => :album_cover_changed.t, :layout => false
    else
      flash_message(:album_cover_changed.t)
      redirect_to page_url(@page, :action => 'edit')
    end
  rescue ArgumentError # happens with wrong ID
    raise PermissionDenied
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
    if params[:image_id]
      image = Asset.find(params[:image_id])
      unless image
        raise "Image not found."
      end
      current_user.may! :view, image
      filepath = image.private_filename
      filename = (image.page ?
                  image.page.title.sub(' ', '_')+'.'+
                  image.filename.split('.').last :
                  image.filename)
      filename = "#{image.page.title.sub(' ','_')}.#{image.filename.split('.').last}"
    else
      name_base = @page.title.gsub(/\s/,'-')
      file = (Dir.entries(GALLERY_ZIP_PATH) - %w{. ..}).map { |e|
        (m = e.match(/^#{name_base}_(\d+).zip/)) ? [m[1].to_i, e] : nil
      }.compact.sort { |x,y| x[0] <=> y[0] }.last
      filename = "#{name_base}.zip"
      if file && file[0] >= @page.updated_at.to_i
        filepath = "#{GALLERY_ZIP_PATH}/#{file[1]}"
      else
        filepath = "#{GALLERY_ZIP_PATH}/#{name_base}_#{Time.now.to_i}.zip"
        Zip::ZipFile.open(filepath, Zip::ZipFile::CREATE) { |zip|
          @page.images.each do |image|
            # multiple images could have the same name, so add the ID
            image_filename = image.filename
            extension = image_filename.split('.').last
            image_name = image_filename[0..(image_filename.size-extension.length-2)]+"_#{image.id}.#{extension}"
            
            zip.get_output_stream(image_name) { |f|
              f.write File.read(image.private_filename)
            }
          end
        }
      end
    end
    send_file(filepath, :filename => filename)
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
    current_user.updated(@page)
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
    @page.add_image!(asset, current_user, params[:position])
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
    if params[:cancel]
      return redirect_to(create_page_url(nil, :group => params[:group]))
    elsif request.post?
      begin
        @page = create_new_page!(@page_class)
        params[:assets].each do |file|
          next if file.size == 0 # happens if no file was selected
          asset = Asset.make(:uploaded_data => file)
          @page.add_image!(asset, current_user)
        end
        return redirect_to create_page_url(AssetPage, :gallery => @page.id) if params[:add_more_files]
        return redirect_to(page_url(@page))
      rescue Exception => exc
        @page = exc.record
        flash_message_now :exception => exc
      end
    end
  end
  
  def upload
    logger.fatal 'go ahead'
    if request.xhr?
      render :layout => false
    elsif request.post?
      params[:assets].each do |file|
        next if file.size == 0
        asset = Asset.make(:uploaded_data => file)
        @page.add_image!(asset, current_user)
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
    elsif action?(:add, :remove, :find, :upload, :add_star, :remove_star,
                  :change_image_title, :make_cover)
      current_user.may?(:edit, @page)
    elsif action?(:show, :comment_image, :detail_view, :slideshow, :download)
      @page.public? or current_user.may?(:view,@page)
    else
      current_user.may?(:admin, @page)
    end  
  end
  
  def setup_view
    @image_count = @page.images.size if @page
    @show_right_column = true
    if !action?(:show) && @page
      @title_addendum = render_to_string(:partial => 'back_link')
    end
    if action?(:detail_view)
      @discussion = false # disable load_posts()
      @show_posts = true
   end
  end

  
end

