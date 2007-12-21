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
  
  # page_name: the name of the parameter in the url
  #            (ie ?section=4 or ?posts=3)
  # pages: a Paginator for the list of objects
  def pagination(page_name, pages) 
    return unless pages and pages.page_count > 1
    
    html = ""
    html += '<div class="pagination"><ul>'

    if pages.current.previous
      html += '<li class="nextpage">%s</li> ' % plink_to('&laquo; ' + 'previous'.t, { page_name => pages.current.previous })
    else
      html += '<li class="disablepage">&laquo; %s</li> ' % 'previous'.t
    end

    last_page = 0
    html += windowed_pagination_links(pages, :window_size => 2,
    :link_to_current_page => true, :always_show_anchors => true) do |n|
      if pages.current.number == n
        li = '<li class="currentpage">%s</li> ' % n
      elsif last_page+1 < n
        li = '<li>... %s</li> ' % plink_to(n, page_name => n)
      else
        li = '<li>%s</li> ' % plink_to(n, page_name => n)
      end
      last_page = n 
      li
    end
  
    if pages.current.next
      html += '<li class="nextpage">%s</li> ' % plink_to('next'.t + ' &raquo;', { page_name => pages.current.next })
    else
      html += '<li class="disablepage">%s &raquo;</li> ' % 'next'.t
    end
    html += '</ul></div>'
    return html
  end
  
  # a special link_to for doing pagination
  
  def plink_to(title, section)
    if @page
      link_to title, page_url(@page, section)
    else
      link_to(title, request.path + build_query_string(section))
    end
  end
  
end

