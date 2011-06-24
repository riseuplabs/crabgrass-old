class GalleryImageController < BasePageController

  # TODO: check if these still work with the new controller and action names
  permissions 'gallery'
  helper 'gallery'

  # could we verify delete as the method on destry?
  verify :method => :post, :only => [:create]
  verify :method => :delete, :only => [:destroy]


  def show
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

  # TODO we still lack an edit action so far
  def edit
  end

  def update
    if request.post?
      # whoever may edit the gallery, may edit the assets too.
      raise PermissionDenied unless current_user.may?(:edit, @page)
      @image = @page.images.find(params[:id])
      # params[:image] would be something like {:cover => 1} or {:title => 'some title'}
      if @image.update_attributes!(params[:image])
        redirect_to page_url(@page, :action => 'image-show', :id => @image.id)
      else
        # raise an error
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
    if request.xhr?
      render :layout => false
    # TODO: make sure zip upload works with server side detection
    elsif request.post? && params[:zipfile]
      @assets, @failures = Asset.make_from_zip(params[:zipfile])
      @assets.each do |asset|
        @page.add_image!(asset, current_user)
      end
      redirect_to page_url(@page)
    elsif request.post?
      params[:assets].each do |file|
        next if file.size == 0
        asset = Asset.create_from_params(:uploaded_data => file)
        @page.add_image!(asset, current_user)
      end
      redirect_to page_url(@page)
    end
  end

  # TODO: we cddan remove the assets all together now that we
  # only allow them to be attached to one gallery
  # kclair: doesn't this only remove the one image since it's in the GalleryImageController  ?
  def destroy
    asset = Asset.find(params[:id])
    @page.remove_image!(asset)
    asset.destroy  ## ???
    if request.xhr?
      undo_link = undo_remove_link(params[:id], params[:position])
      js = javascript_tag("remove_image(#{params[:id]});")
      render(:text => I18n.t(:successfully_removed_image, :undo_link => undo_link) + js,
             :layout => false)
    else
      redirect_to page_url(@page)
    end
  end

  # TODO: turn these into more restful actions
  # kclair: hmm these are actions that viewers can add, not necessarily ppl who can edit the gallery
  # kclair: so i'm not sure they belong in update?
  def comment
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
