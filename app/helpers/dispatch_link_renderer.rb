
class DispatchLinkRenderer < WillPaginate::LinkRenderer
  def url_for(page)
#    require 'ruby-debug'; debugger
    url = ""
    url += "/#{@template.params[:_context]}" if @template.params[:_context]
    url += "/#{@template.params[:_page]}" if @template.params[:_page]
    url += "?posts=#{page}"

    return url
  end
end

