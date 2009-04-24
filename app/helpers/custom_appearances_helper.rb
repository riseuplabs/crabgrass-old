module CustomAppearancesHelper
  def display_masthead
    if @appearance.masthead_asset
      content_tag :div, :id => "masthead_preview" do
        image_tag(@appearance.masthead_asset.url, :alt => @appearance.masthead_asset.filename)
      end
    else
      ""
    end
  end
end
