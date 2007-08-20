# http://www.hervalfreire.com/blog/2007/05/11/faster-pagination-reloaded/

module PaginationHelper  

  def windowed_pagination_links(pagingEnum, options)  
    link_to_current_page = options[:link_to_current_page]  
    always_show_anchors = options[:always_show_anchors]  
    padding = options[:window_size]  
      
    current_page = pagingEnum.current.number  
    html = ''  
     
    # Calculate the window start and end pages  
    padding = padding < 0 ? 0 : padding  
    if pagingEnum.page_count <= (current_page - padding)
      first = current_page - padding
    else
      first = 1  
    end
    if pagingEnum.page_count > (current_page + padding)
      last = current_page + padding
    else
      last = pagingEnum.last_page.number  
    end
    
    # Print start page if anchors are enabled  
    if always_show_anchors and not first == 1  
      html << yield(1) 
    end
    
    # Print window pages  
    first.upto(last) do |page|  
      if current_page == page && !link_to_current_page
        html << page.number
      else
        html << yield(page)
      end
    end  
     
    # Print end page if anchors are enabled
    if always_show_anchors and not last == pagingEnum.last_page.number  
      html << yield(pagingEnum.last_page.number)
    end
    
    html  
  end
    
end

