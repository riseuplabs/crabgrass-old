class Tool::RequestController < Tool::BaseController
  
  append_before_filter :fetch_request
  def fetch_request
    @request = @page.data || @page.model.new
  end
  
  def show
    @link = @page.links.first if @page.links.any?
  end

  def approve
    if @request.approve(:by => current_user)
      current_user.updated(@page, :all_resolved => true)
      message :text => 'request approved'
      redirect_to from_url(@page)
    else  
      message :object => @request
    end
  end
  
  def reject
    if @request.reject(:by => current_user)
      current_user.updated(@page, :all_resolved => true)
      message :text => 'request rejected'
      redirect_to from_url(@page)
    else  
      message :object => @request
    end
  end
  
  protected 
  
  def context
    # perhaps this could be done better by subclassing RequestController
    if @page.flow == FLOW[:contacts]
      me_context
      add_context 'requests', url_for(:controller => 'requests')
    elsif @page.flow == FLOW[:membership]
      group_context @page.group
      add_context 'membership', url_for(:controller => 'membership', :id => @page.group)
    else
      super
    end
  end
  
  def setup_view
    @show_tags = false
    @show_attach = false
    @show_links = false
  end
  
end
