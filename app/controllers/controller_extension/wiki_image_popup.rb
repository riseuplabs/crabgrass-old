module ControllerExtension::WikiImagePopup
  # xhr only
  def image_popup_show
    @images = image_popup_visible_images
    popup_id = 'image_popup-' + @wiki.id.to_s
    render(:update) do |page| 
      page.replace popup_id, :partial => 'wiki/image_popup', :locals => {:wiki => @wiki}
    end
  end

  # upload image via xhr
  # response goes to an iframe, so requires responds_to_parent
  def image_popup_upload
    asset = Asset.build params[:asset]
    if @page
      asset.parent_page = @page
    else
      # something something
    end
    asset.save
    @images = image_popup_visible_images
    popup_id = 'image_popup-' + @wiki.id.to_s
    responds_to_parent do
      render(:update) do |page|
        page.replace popup_id, :partial => 'wiki/image_popup', :locals => {:wiki => @wiki}
      end
    end
  end
end