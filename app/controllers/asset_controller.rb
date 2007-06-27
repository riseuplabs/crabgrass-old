class AssetController < ApplicationController
  prepend_before_filter :fetch_asset

  def show
    send_file(@asset.full_filename, :filename => @asset.filename)
  end

  protected

  def fetch_asset
    @asset = Asset.find(params[:id], :include => 'pages') if params[:id]
  end

  def authorized?
    if @asset
      current_user.may?(:read, @asset.page)
    else
      false
    end
  end
end

