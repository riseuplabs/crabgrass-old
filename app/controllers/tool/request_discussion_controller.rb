class Tool::RequestDiscussionController < Tool::BaseController

  def show
    @comment_header = ""
    @link = @page.links.first if @page.links.any?
  end
  
  protected
  
  def setup_view
    @show_reply = true
    @show_attach = false
    @show_links = false
    @show_tags = false
  end
  
end

