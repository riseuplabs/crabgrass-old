module Tool::AssetHelper
  def icon_for(asset)
    icon = if asset.image?
      'pages/image.png'
    elsif asset.document?
      'pages/document.png'
    else
      'pages/package.png'
    end
    image_tag icon
  end
end
