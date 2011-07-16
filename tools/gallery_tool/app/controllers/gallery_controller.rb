class GalleryController < BasePageController

  stylesheet 'gallery'
  stylesheet 'upload', :only => :edit
  javascript :extra, 'page'
  javascript :upload, :only => :edit
  permissions 'gallery'

  include GalleryHelper
  include BasePageHelper
  include ActionView::Helpers::JavascriptHelper


  def show
    @images = paginate_images
    #@cover = @page.cover
  end

  def edit
    @images = paginate_images
  end

  # maybe call this update?
  # TODO: this has not been tested or played with
  # what exactly is this updating?
  def update
    # kclair: i think all of the sort functionality should really update the images directly and use the GalleryImageController
    if ids = params[:sort_gallery]
      text =""
      ids.each_with_index do |id, index|
        showing = @page.showings.find_by_asset_id(id)
        showing.insert_at(index)
      end
    elsif params[:id]
      # TODO: make sure the non ajax fallback still works
      # This should most likely move into the GalleryImageController
      showing = @page.showings.find_by_asset_id(params[:id])
      new_pos = (params[:direction] == 'left') ? showing.position - 1 :
        showing.position + 1
      new_pos = @page.showings.size-1 if new_pos < 0
      new_pos = 0 if new_pos > new_pos.size-1
      showing.insert_at(new_pos)
    end
    @page.update_attributes!(params[:page])
    current_user.updated(@page)
    if request.xhr?
      render :text => I18n.t(:order_changed), :layout => false
    else
      flash_message_now I18n.t(:order_changed)
      redirect_to(:controller => 'gallery',
                  :action => 'edit',
                  :page_id => @page.id)
    end
  rescue => exc
    render :text => I18n.t(:error_saving_new_order_message) %{ :error_message => exc.message}
  end

  protected

  def setup_view
    @image_count = @page.images.size if @page
    @show_right_column = true
  end

  def build_page_data
    @assets ||= []
    params[:assets].each do |file|
      next if file.size == 0 # happens if no file was selected
      build_asset_data(@assets, file)
    end

    # gallery page has no 'data' field
    return nil
  end

  def build_asset_data(assets, file)
    asset = Asset.create_from_param_with_zip_extraction(file) do |asset|
      asset.parent_page = @page
    end
    asset.each do |a|
      @assets << a
      @page.add_image!(a, current_user)
      a.save!
    end
    @assets
  end

  def build_zip_file_data(assets, file)
    zip_assets, failures = Asset.make_from_zip(file)
    zip_assets.each do |asset|
      asset.parent_page = @page
      @assets << asset
      @page.add_image!(asset, current_user)
      asset.save!
    end
  end

  def destroy_page_data
    @assets.compact.each do |asset|
      asset.destroy unless asset.new_record?
      asset.page.destroy if asset.page and !asset.page.new_record?
    end
  end

  #
  # there appears to be a bug in will_paginate. it only appears when
  # doing two inner joins and there are more records than the per_page size.
  #
  # unfortunately, this is what we need for returning the images the current
  # user has access to see.
  #
  # This works as expected:
  #
  #   @page.images.visible_to(current_user).find(:all)
  #
  # That is just great, but we also want to paginate. This blows up horribly,
  # if there are more than three images:
  #
  #  @page.images.visible_to(current_user).paginate :page => 1, :per_page => 3
  #
  # So, this method uses two queries to get around the double join, so that
  # will_paginate doesn't freak out.
  #
  # The first query just grabs all the potential image ids (@page.image_ids)
  #
  def paginate_images
    params[:page] ||= 1
    Asset.visible_to(current_user).paginate(:page => params[:page], :conditions => ['assets.id IN (?)', @page.image_ids])
  end

end

