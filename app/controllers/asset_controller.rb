class AssetController < ApplicationController
  prepend_before_filter :fetch_asset

  def show
    send_file(full_path_to_file, :filename => @asset.filename)
  end

  protected

  def fetch_asset
    @asset = Asset.find(params[:id], :include => 'pages') if params[:id]
  end

  def authorized?(user)
    if @asset
      user.may?(@asset.page, :read)
    else
      false
    end
  end
end

