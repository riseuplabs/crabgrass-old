class AssetController < ApplicationController
  before_filter :fetch_asset

  def show
    send_file(full_path_to_file, :filename => @asset.filename)
  end

  protected
    def fetch_asset
      @asset = Asset.find(params[:id]) if params[:id]
    end

    def authorized?(user)
      user.may?(page, :read)
    end
end
