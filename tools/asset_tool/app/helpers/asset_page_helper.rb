module AssetPageHelper
  def icon_for(asset)
    image_tag asset.big_icon, :style => 'vertical-align: middle'
  end

  def asset_link_with_preview(asset)
    if asset.may_preview? and !asset.has_preview?
      link_to( image_tag('/images/spinner.gif') + " Creating preview", asset.public_filename ) + 
#      javascript_tag remote_function( :update => "page_list", :url => { :action => :page_list })
       javascript_tag(remote_function(:update => "preview-area", :url => { :controller => :asset, :action => :generate_preview, :id => asset.id } ))
    elsif asset.has_preview?
      link_to( image_tag(asset.public_filename(:preview)), asset.public_filename )
    else
      link_to( image_tag(asset.big_icon), asset.public_filename )
    end
  end
end

