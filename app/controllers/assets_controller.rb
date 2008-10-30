class AssetsController < ApplicationController
  before_filter :public_or_login_required
  prepend_before_filter :fetch_asset, :only => [:show, :destroy]
  prepend_before_filter :initialize_asset, :only => :create #maybe we can merge these two filters

  def initialize_asset
    @asset = Asset.new params[:asset]
    message(:error => "Invalid file") and redirect_to(:back) and return false unless @asset.valid?
    @asset.filename = params[:asset_title]+@asset.suffix if params[:asset_title].any?
    true
  end
  
  def show
    if @asset.public? and !File.exists?(@asset.public_filename)
      # update access and redirect iff asset is public AND the public
      # file is not yet in place.
      @asset.update_access
      @asset.generate_thumbnails
      if @asset.thumbnails.any?
        redirect_to # redirect to the same url again, but next time they will get the symlinks 
      else
        return not_found
      end
    else
      path = params[:path].first
      if thumb_name_from_path(path)
        thumb = @asset.thumbnail( thumb_name_from_path(path) )
        return not_found unless thumb
        thumb.generate
        send_file(thumb.private_filename, :type => thumb.content_type, :disposition => disposition(thumb))
      else
        send_file(@asset.private_filename, :type => @asset.content_type, :disposition => disposition(@asset))
      end
    end
  end

  def destroy
    @asset.destroy
    respond_to do |format|
      format.js { render :nothing => true }
      format.html do
        message(:success => "file deleted") 
        redirect_to(page_url(@asset.page))
      end
    end
  end

  def create
    @asset = Asset.new params[:asset]
    @asset.filename = params[:asset_title]+@asset.suffix if params[:asset_title].any?
    @asset.save
    flash_message_now :object => @asset
    redirect_to page_url(@asset.page)
  end

  protected

  def fetch_asset
    if params[:version]
      @asset = Asset.find_by_id(params[:id]).versions.find_by_version(params[:version])
    else
      @asset = Asset.find_by_id(params[:id])
    end
    return not_found unless @asset
    true
  end

  # guess if we are viewing a thumbnail or the actual asset
  def thumbnail_filename?(filename)
    filename =~ /#{THUMBNAIL_SEPARATOR}/
  end

  def public_or_login_required
    return true unless @asset
    @asset.public? or login_required
  end

  def authorized?
    if @asset
      if action_name == 'show' || action_name == 'version'
        current_user.may?(:view, @asset)
      elsif action_name == 'create' || action_name == 'destroy'
        current_user.may?(:edit, @asset.page)
      end
    else
      false
    end
  end

  def access_denied
    flash_message :error => 'You do not have sufficient permission to access that file' if logged_in?
    flash_message :error => 'Please login to access that file.' unless logged_in?
    redirect_to :controller => '/account', :action => 'login', :redirect => request.request_uri
  end
  
  def thumb_name_from_path(path)
    $~[1].to_sym if path =~ /#{THUMBNAIL_SEPARATOR}(.+)\./
  end

  # returns 'inline' for formats that web browsers can display, 'attachment' otherwise.
  def disposition(asset)
    if ['image/png','image/jpeg','image/gif'].include? asset.content_type
      'inline'
    else
      'attachment'
    end
  end

  def not_found
    render :action => 'not_found', :layout => false, :status => :not_found
    false
  end
end

