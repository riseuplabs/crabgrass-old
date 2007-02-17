
class RequestController < ToolController
  layout :page

  # inherited actions
  # destroy
  # breadcrumbs
  
  def show
    @request = @page.tool
  end

  def new
  end
  
end
