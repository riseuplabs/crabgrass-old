module LocationsHelper

  # <%= select('group','location', GeoCountry.find(:all).to_select(:name, :code), {:include_blank => true}) %>
  def country_dropdown(object, method)
    onchange = remote_function(
      :url => {:controller => 'locations', :action => 'replace_admin_codes_options'},
      :with => "'country_code='+value"
    ) 
    select(object,method, GeoCountry.find(:all).to_select(:name, :code), {:include_blank => true},{:onchange => onchange})
  end

#  def sidebar_checkbox(text, checked, url, li_id, checkbox_id, options = {})
#    click = remote_function(
#      :url => url,
#      :loading  => hide(checkbox_id) + add_class_name(li_id, 'spinner_icon')
#      :complete => show(checkbox_id) + remove_class_name(li_id, 'spinner_icon')
#    )
#    out = []
#    #out << "<label id='#{checkbox_id}_label'>" # checkbox labels don't work in IE
#    out << check_box_tag(checkbox_id, '1', checked, :class => 'check', :onclick => click)
#    out << link_to_function(text, click, :class => 'check', :title => options[:title])
#    #out << '</label>'
#    out.join
#  end

#  def watch_line
#    if may_watch_page?
#      existing_watch = (@upart and @upart.watch?) or false
#      li_id = 'watch_li'
#      checkbox_id = 'watch_checkbox'
#      url = {:controller => 'base_page/participation', :action => 'update_watch',
#             :add => !existing_watch, :page_id => @page.id}
#      checkbox_line = sidebar_checkbox(I18n.t(:watch_checkbox), existing_watch, url, li_id, checkbox_id)
#      content_tag :li, checkbox_line, :id => li_id, :class => 'small_icon'
#    end
#  end

end
