module BasePage::TrashHelper

  def destroy_page_line
    if current_user.may?(:delete, @page)
      link = link_to("Shred :page_class"[:destroy_page_link] % { :page_class => page_class },
                     page_xurl(@page, :controller => 'base_page/trash', :action => 'destroy'),
                     :method => 'post',
                     :confirm => 'Are you sure you want to destroy this page? It cannot be undeleted.'[:confirm_destroy_page])
      content_tag :li, link, :class => 'small_icon minus_16'
    end
  end

  def trash_page_line
    if current_user.may?(:admin, @page)
      link = link_to("Move :page_class to dumpster"[:trash_page_link] % { :page_class => page_class },
                     page_xurl(@page, :controller => 'base_page/trash', :action => 'delete'),
                     :method => 'post')
      content_tag :li, link, :class => 'small_icon trash_16'
    end
  end

end
