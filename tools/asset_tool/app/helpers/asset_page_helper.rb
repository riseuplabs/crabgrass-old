module AssetPageHelper

  def asset_link_with_preview(asset)
    thumbnail = asset.thumbnail(:large)
    if thumbnail.nil?
      link_to( image_tag(asset.big_icon), asset.url )
    elsif !thumbnail.exists?
      #if false and thumbnail.width
      #  width = thumbnail.width
      #  height = thumbnail.height
      #else
      #  width, height = thumbnail.thumbdef.size.split /[x><]/
      #end
      width, height = [300,300]
      style = "height:#{height}px; width:#{width}px;"
      style += "background: white url(/images/spinner-big.gif) no-repeat 50% 50%;"
      javascript = javascript_tag(remote_function(:url => page_xurl(@page,:action => 'generate_preview')))
      content_tag(:div, '', :id=>'preview-loading', :style => style) + javascript
    else
      link_to_asset(asset, :large, :class => '')
    end
  end

  def download_link
    image_tag('actions/download.png', :size => '32x32', :style => 'vertical-align: middle;') + link_to("Download", @asset.url)
  end

  def upload_link
    image_tag('actions/upload.png', :size => '32x32', :style => 'vertical-align: middle;') + link_to_function("Upload new version", "$('upload_new').toggle()") if current_user.may?(:edit, @page)
  end

  def destroy_version_link(version)
    action = {
      :url => page_xurl(@page, :action => 'destroy_version', :id => version.version),
      :confirm => I18n.t(:delete_version_confirm),
      :before => "$($(this).up('td')).addClassName('busy')",
      :failure => "$($(this).up('td')).removeClassName('busy')"
    }
    link_to_remote(image_tag('actions/delete.png'), action, :title => I18n.t(:delete_this_version))
    # non-ajax? {:href => url_for(:controller => 'asset', :action => 'destroy', :id => @asset.id)})
  end

  def preview_area_class(asset)
    'checkerboard' if asset.thumbnail(:large)
  end
end

