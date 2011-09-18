class GalleryImageController < BasePageController

  permissions 'gallery'
  helper 'gallery', 'progress_bar'

  # could we verify delete as the method on destry?
  verify :method => :post, :only => [:create]
  verify :method => [:post, :put], :only => [:update]
  verify :method => [:post, :delete], :only => [:destroy]

  def show
    return unless request.xhr?
    @showing = @page.showings.find_by_asset_id(params[:id], :include => 'asset')
    @image = @showing.asset
    @track = @showing.track
    # position sometimes starts at 0 and sometimes at 1?
    @image_index = @page.images.index(@image).next
    @image_count = @page.showings.count
    @next = @showing.lower_item
    @previous = @showing.higher_item
    #raise 'next is '+@next.inspect+' and previous is '+@previous.inspect
    render :update do |page|
      page.replace_html 'gallery-container', :partial => 'show'
      page.hide 'posts'
    end
  end

  def edit
    @showing = @page.showings.find_by_asset_id(params[:id], :include => 'asset')
    @image = @showing.asset
    @track = @showing.track || Track.new
    @image_upload_id = (0..29).to_a.map {|x| rand(10)}.to_s
    @track_upload_id = (0..29).to_a.map {|x| rand(10)}.to_s
    if request.xhr?
      render :layout => false
    end
  end

  def update
    # whoever may edit the gallery, may edit the assets too.
    raise PermissionDenied unless current_user.may?(:edit, @page)
    @image = @page.images.find(params[:id])
    if params[:assets] #and request.xhr?
      begin
        @image.change_source_file(params[:assets].first)
        # reload might not work if the class changed...
        @image = Asset.find(@image.id)
        responds_to_parent do
          render :update do |page|
            page.replace_html 'show-image', :partial => 'show_image',
              :locals => {:size => 'medium', :no_link => true}
            page.hide('progress')
            page.hide('update_message')
          end
        end
      rescue Exception => exc
        responds_to_parent do
          render :update do |page|
            page.hide('progress')
            page.replace_html 'update_message', $!
          end
        end
      end
    # params[:image] would be something like {:cover => 1} or {:title => 'some title'}
    elsif params[:image] and @image.update_attributes!(params[:image])
      @image.reload
      respond_to do |format|
        format.html { redirect_to page_url(@page,:action=>'show') }
        format.js { render :partial => 'update', :locals => {:params => params[:image]} }
      end
    end
  end

  def new
    @upload_id = (0..29).to_a.map {|x| rand(10)}.to_s
    if request.xhr?
      render :layout => false
    end
  end

  def create
    params[:assets].each do |param|
      assets = Asset.create_from_param_with_zip_extraction(param)
      assets.each do |asset|
        @page.add_image!(asset, current_user)
      end
    end
    redirect_to page_url(@page)
  end

  def destroy
    asset = Asset.find(params[:id])
    @page.remove_image!(asset)  # this also destroys the asset
    if request.xhr?
      render :layout => false
    else
      redirect_to page_url(@page)
    end
  end

  protected

  # just carrying over stuff from the old gallery controller here
  def setup_view
    @show_right_column = true
    if action?(:show)
      @discussion = false # disable load_posts()
      @show_posts = true
    end
  end

end
