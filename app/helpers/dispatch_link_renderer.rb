
class DispatchLinkRenderer < WillPaginate::LinkRenderer
  def url_for(page)
    #require 'ruby-debug'; debugger
    if @template.params[:_context] or @template.params[:_page]
      url = ""
      url += "/#{@template.params[:_context]}" if @template.params[:_context]
      url += "/#{@template.params[:_page]}" if @template.params[:_page]
      url += "/#{@options[:params][:action]}" if @options[:params] and @options[:params][:action]
      url += "?#{param_name}=#{page}"
      # TODO: handle other params in addition to :action. 
      return url
    else
      super(page)
    end
  end
end

