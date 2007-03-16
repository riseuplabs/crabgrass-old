class Tool::RequestController < Tool::BaseController
  
  append_before_filter :fetch_request
  
  def fetch_request
    @request = @page.data
  end
  
  def show
  end

  def approve
    if @request.approve(:by => current_user)
      current_user.updated(@page)
      message :text => 'request approved'
      redirect_to from_url
    else  
      message :object => @request
    end
  end
  
  def reject
    if @request.reject(:by => current_user)
      current_user.updated(@page)
      message :text => 'request rejected'
      redirect_to from_url
    else  
      message :object => @request
    end
  end
    
end
