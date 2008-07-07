module AssetPageHelper
  def icon_for(asset)
    image_tag asset.big_icon, :style => 'vertical-align: middle'
  end

  def asset_link_with_preview(asset)
    if asset.may_preview? and !asset.has_preview?
      "<div id='preview-loading'>" + image_tag('/images/spinner-big.gif') + "<br/>" + " generating preview" + "</div>" +
      javascript_tag(remote_function(:url => page_xurl(@page,:action => 'generate_preview')))
    elsif asset.has_preview?
      link_to(
        image_tag(asset.public_filename(:preview)),
        asset.public_filename
      )
    else
      link_to( image_tag(asset.big_icon), asset.public_filename )
    end
  end
end

