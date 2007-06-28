module Tool::AssetHelper
  def icon_for(asset)
    image_tag asset.big_icon
  end
end

