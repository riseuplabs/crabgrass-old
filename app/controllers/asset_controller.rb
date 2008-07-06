class AssetController < ApplicationController

  before_filter :public_or_login_required, :except => :generate_preview
  
  prepend_before_filter :fetch_asset, :only => [:show, :destroy]
  prepend_before_filter :initialize_asset, :only => :create #maybe we can merge these two filters

  def show
    send_file(@asset.full_filename(@thumb), :type => @asset.content_type, :disposition => (@asset.image? ? 'inline' : 'attachment'))
  end

  def create
    if @asset.save
      return redirect_to(page_url(@asset.page))
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

  def generate_preview
#        returning find_or_initialize_thumbnail(file_name_suffix) do |thumb|
#          thumb.attributes = {
#            :content_type             => content_type,
#            :filename                 => thumbnail_name_for(file_name_suffix),
#            :temp_path                => temp_file,
#            :thumbnail_resize_options => size
#          }
    @asset = Asset.find(params[:id])
    preview = Asset.create(:thumbnail => "preview",
                           :parent => @asset,
                           :content_type => 'image/png',
                           :filename => @asset.thumbnail_name_for("preview") + ".png",
                           :temp_path => 'public/images/crabgrass.png')
    preview.save!
  end

  protected

  def fetch_asset
    @thumb = nil
    @asset = Asset.find(params[:id]).versions.find_by_version(params[:version]) if params[:version]
    @asset ||= Asset.find(params[:id], :include => ['pages', 'thumbnails']) if params[:id]
    if @asset && @asset.image? && (filename = params[:filename].first) && filename != @asset.filename
      thumb = @asset.thumbnails.detect {|a| filename == a.filename }
      render(:text => "Not found", :status => :not_found) and return unless thumb
      @thumb = thumb.thumbnail.to_sym
      @asset.create_or_update_thumbnail(@asset.full_filename,@thumb,Asset.attachment_options[:thumbnails][@thumb]) unless File.exists? thumb.full_filename
    end
    if @asset.is_public?
      @asset.update_access 
      redirect_to and return false
    end
  end

  def initialize_asset
    @asset = Asset.new params[:asset]
    message(:error => "Invalid file") and redirect_to(:back) and return false unless @asset.valid?
    @asset.filename = params[:asset_title]+@asset.suffix if params[:asset_title].any?
    true
  end

  protected

  def public_or_login_required
    @asset.page.public? or login_required
  end
  
  def authorized?
    if @asset
      if action_name == 'show' || action_name == 'version'
        current_user.may?(:read, @asset.page)
      elsif action_name == 'create' || action_name == 'destroy'
        current_user.may?(:edit, @asset.page)
      end
    else
      false
    end
  end

  def access_denied
    message :error => 'You do not have sufficient permission to access that file' if logged_in?
    message :error => 'Please login to access that file.' unless logged_in?
    redirect_to :controller => '/account', :action => 'login', :redirect => @request.request_uri
  end
  
  
end

