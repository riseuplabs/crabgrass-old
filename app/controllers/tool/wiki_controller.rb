class Tool::WikiController < Tool::BaseController

  append_before_filter :fetch_wiki
  
  def show
    
  end

  def edit
    if params[:cancel]
       return(redirect_to page_url(@page, :action => 'show'))
    elsif request.post?
      @wiki.body = params[:wiki][:body]
      @wiki.user = current_user
      if @wiki.save
        current_user.wrote(@page)
        redirect_to page_url(@page, :action => 'show')
      else
        message :object => @wiki
      end
    end
  end
  
  def version
    @version = @wiki.versions.find_by_version(params[:version])
  end
  
  def preview
  
  end
  
  def save
  
  end
  
  def fetch_wiki
    @wiki = @page.data
  end
  
end
