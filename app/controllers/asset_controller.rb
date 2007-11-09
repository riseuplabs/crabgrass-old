class AssetController < ApplicationController

  before_filter :public_or_login_required
  
  prepend_before_filter :fetch_asset, :only => [:show, :destroy]
  prepend_before_filter :initialize_asset, :only => :create #maybe we can merge these two filters

  def show
    send_file(@asset.full_filename(@thumb), :type => @asset.content_type, :disposition => (@asset.image? ? 'inline' : 'attachment'))
  end

  def create
    if @asset.save
#      if params[:title] || params[:tag_list]
#        params[:page] = {:title => params[:title]}
#        @page = build_new_page
#        @page.data = @asset
#        @page.save
#      end
      return redirect_to(page_url(@asset.page))
    end
  end

  def destroy
    @asset.destroy
    respond_to do |format|
      format.js do
        render :update do |page|
          page.remove "asset_#{@asset.id}"
          page.alert "Attachment deleted"
        end
      end
      format.html do
        message(:success => "Attachment deleted") 
        redirect_to(page_url(@asset.page))
      end
    end
  end

  protected

  def fetch_asset
    @thumb = nil
    @asset = Asset.find(params[:id], :include => ['pages', 'thumbnails']) if params[:id]
    @asset = @asset.versions[params[:version].to_i - 1] if params[:version]
    if @asset && @asset.image? && params[:filename] && params[:format] && @asset.filename != "#{params[:filename]}.#{params[:format]}"
      thumb = @asset.thumbnails.detect {|a| a.filename == "#{params[:filename]}.#{params[:format]}"}
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
    store_location
    message :error => 'You do not have sufficient permission to access that file' if logged_in?
    message :error => 'Please login to access that file.' unless logged_in?
    redirect_to :controller => '/account', :action => 'login'
  end
  
  
end

