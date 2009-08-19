module ControllerExtension::WikiPopup
  # xhr only
  def image_popup_show
    @images = image_popup_visible_images
    popup_id = 'image_popup-' + @wiki.id.to_s
    #render(:update) do |page|
    #  page.replace popup_id, :partial => 'wiki/image_popup', :locals => {:wiki => @wiki}
    #end
    render :partial => 'wiki/image_popup', :locals => {:wiki => @wiki}
  end

  # upload image via xhr
  # response goes to an iframe, so requires responds_to_parent
  def image_popup_upload
    asset = Asset.build params[:asset]

    # create a page for this asset
    # this will only be used for group wikis
    unless @page
      asset_page_params = {
        :title => asset.basename,
        :summary =>"some summary2",
        :tag_list => "",
        :user => current_user,
        :share_with => {@group.name => {:access =>  "1"}},
        :access => "admin",
        :data => asset
        }
      @page = AssetPage.create!(asset_page_params)
    end

    asset.parent_page = @page
    asset.save
    @images = image_popup_visible_images
    popup_id = 'image_popup-' + @wiki.id.to_s
    responds_to_parent do
      render(:update) do |page|
        page.replace popup_id, :partial => 'wiki/image_popup', :locals => {:wiki => @wiki}
      end
    end
  end

  def link_popup_show
    render :partial => 'wiki/link_popup', :locals => {:wiki => @wiki}
  end

end
