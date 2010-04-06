module BasePage::TrashHelper

#  def destroy_page_line
#    if current_user.may?(:delete, @page)
#      link = link_to(I18n.t(:destroy_page_link, :page_class => page_class),
#         {:page_id => @page.id, :controller => '/base_page/trash', :action => 'destroy'},
#         :method => 'post', :confirm => I18n.t(:confirm_destroy_page))
#      content_tag :li, link, :class => 'small_icon minus_16'
#    end
#  end

#  def trash_page_line
#    if current_user.may?(:admin, @page)
#      link = link_to(I18n.t(:trash_page_link, :page_class => page_class),
#                     page_xurl(@page, :controller => '/base_page/trash', :action => 'delete'),
#                     :method => 'post')
#      content_tag :li, link, :class => 'small_icon trash_16'
#    end
#  end

end
