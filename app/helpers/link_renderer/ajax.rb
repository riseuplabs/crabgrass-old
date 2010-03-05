#
# See for other ways of doing ajax pagination:
#  http://weblog.redlinesoftware.com/2008/1/30/willpaginate-and-remote-links
#
#
class LinkRenderer::Ajax < LinkRenderer::Dispatch
  def page_link(page, text, attributes = {})
    options = {:url => url_for(page)}
    if attributes[:class] =~ /prev_page/
   #   attributes[:icon] = 'left'
   #   attributes[:style] = 'padding-left: 20px'
    elsif attributes[:class] =~ /next_page/
   #   attributes[:icon] = 'right'
   #   attributes[:class] += ' right'
   #   attributes[:style] = 'padding-right: 20px'
    else
      attributes[:icon] = 'none'
    end
    @template.link_to_remote(text, options, attributes)
  end

  def page_span(page, text, attributes = {})
    if attributes[:class] =~ /prev_page/
    #  attributes[:class] += " small_icon left_16"
    #  attributes[:style] = 'padding-left: 20px'
    elsif attributes[:class] =~ /next_page/
    #  attributes[:class] += " small_icon right_16 right"
    #  attributes[:style] = 'padding-right: 20px'
    end
    @template.content_tag :span, text, attributes
  end

end

