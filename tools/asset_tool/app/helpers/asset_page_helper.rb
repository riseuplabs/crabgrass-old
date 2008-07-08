module AssetPageHelper
  def icon_for(asset)
    image_tag asset.big_icon, :style => 'vertical-align: middle'
  end

  def mini_thumb_for(asset)
    # TODO: get thumbnails working for versioned assets
    # asset.has_thumbnail? ? image_tag(asset.public_filename(:thumb)) : image_tag(asset.small_icon)
    image_tag(asset.small_icon)
  end

  def asset_link_with_preview(asset)
    if asset.may_thumbnail? and !asset.has_thumbnail?
      "<div id='preview-loading'>" + image_tag('/images/spinner-big.gif') + "<br/>" + " generating preview" + "</div>" +
      javascript_tag(remote_function(:url => page_xurl(@page,:action => 'generate_preview')))
    elsif asset.has_thumbnail?
      link_to(
        image_tag(asset.public_filename(:preview)),
        asset.public_filename
      )
    else
      link_to( image_tag(asset.big_icon), asset.public_filename )
    end
  end
end

