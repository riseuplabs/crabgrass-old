module BasePage::AssetsHelper

  # TODO: fix styles so that we don't have to force no padding here
  def asset_row(asset)
    content_tag(:td, 
      link_to(thumbnail_img_tag(asset, :small), asset.url, :class => 'plain', :style => 'padding:0;'),
      :style => 'vertical-align:top; width: 1%;' 
    ) +
    content_tag(:td,
      link_to( h(asset.filename), asset.url, :style => 'padding:0') +
      remove_asset_link(asset),
      :style => 'vertical-align:top;'
    )
  end

  def asset_rows
    @page.assets.collect do |asset|
      content_tag(:tr, asset_row(asset), :id => dom_id(asset), :class => cycle('even','odd'))
    end.join("\n")
  end

  def remove_asset_link(asset)
    link = link_to_remote("(remove)",
      :url => {:controller => 'base_page/assets', :action => 'destroy', :id => asset.id, :page_id => @page.id},
      :html => {:style => 'display:inline; padding:0;'},
      :confirm => 'Are you sure you want to delete this attachment?',
      :loading  => show_spinner('popup'),
      :complete => hide(dom_id(asset)) + hide_spinner('popup')
    )
  end
end

