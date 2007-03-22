class Tool::WikiController < Tool::BaseController
  include HTMLDiff
  append_before_filter :fetch_wiki
  
  def show
    unless @wiki.version
      redirect_to page_url(@page, :action => 'edit')
      return
    end
    if @upart and not @upart.viewed? and @wiki.version.to_i > 1
      @diffhtml = html_diff(
         @wiki.find_version(@wiki.version.to_i-1).body_html,
         @wiki.body_html
      )
    end
  end

  def edit
    if params[:cancel]
       return(redirect_to page_url(@page, :action => 'show'))
    elsif request.post?
      @wiki.body = params[:wiki][:body]
      @wiki.user = current_user
      if @wiki.save
        current_user.updated(@page)
        redirect_to page_url(@page, :action => 'show')
      else
        message :object => @wiki
      end
    end
  end
  
  def version
    @version = @wiki.versions.find_by_version(params[:version])
  end
  
  def diff
    @old = @wiki.find_version(params[:old])
    @new = @wiki.find_version(params[:new])
    @old_markup = @old.body || ''
    @new_markup = @new.body || ''
    @difftext = html_diff( @old_markup , @new_markup)
  end
  
  def preview
    # not yet
  end
    
  protected
  
  def fetch_wiki
    @page.data ||= Wiki.new(:body => 'new page')
    @wiki = @page.data
  end
  
end
