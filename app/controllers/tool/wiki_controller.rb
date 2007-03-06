class Tool::WikiController < Tool::BaseController

  append_before_filter :fetch_wiki
  
  def show
    
  end

  def edit
    if request.post?
      @wiki.body = params[:wiki][:body]
      #@wiki.body_html = textilize(@wiki.body)
      if @wiki.save
        redirect_to page_url(@page, :action => 'show')
      else
        message :object => @wiki
      end
    end
  end
  
  def preview
  
  end
  
  def save
  
  end
  
  def fetch_wiki
    @wiki = @page.data
  end
  
end
