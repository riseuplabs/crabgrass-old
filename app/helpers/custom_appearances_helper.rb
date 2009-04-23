module CustomAppearancesHelper
  def display_masthead
    if @appearance.masthead_asset
      image_tag(@appearance.masthead_asset.url, :alt => @appearance.masthead_asset.filename)
    else
      ""
    end
  end
end
