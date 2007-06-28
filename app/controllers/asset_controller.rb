class AssetController < ApplicationController
  prepend_before_filter :fetch_asset

  def show
    thumb = nil
    unless @asset.filename == "#{params[:filename]}.#{params[:format]}"
      file = @asset.thumbnails.detect {|a| a.filename == "#{params[:filename]}.#{params[:format]}"}
      thumb = file.thumbnail if file
    end
    send_file(@asset.full_filename(thumb), :type => @asset.content_type, :disposition => (@asset.image? ? 'inline' : 'attachment'))
  end

  protected

  def fetch_asset
    @asset = Asset.find(params[:id], :include => ['pages', 'thumbnails']) if params[:id]
  end

  def authorized?
    if @asset
      current_user.may?(:read, @asset.page)
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

