class WikiPageController < BasePageController
  include HTMLDiff
  append_before_filter :fetch_wiki
  
  def show
    if @upart and !@upart.viewed? and @wiki.version > 1
      @last_seen = @wiki.first_since( @upart.viewed_at )
    end
  end

  def create
    @page_class = WikiPage
    if request.post?
      @page = create_new_page(@page_class)
      if @page.valid?
        fetch_wiki
        @wiki.lock Time.now, current_user
        @page.save # attach the new wiki to the page

        return redirect_to(page_url(@page, :action => 'edit'))
      else
        flash_message_now :object => @page
      end
    end
    render :template => 'base_page/create'
  end

  def edit
    if params[:cancel]
      cancel
    elsif params[:break_lock]
      @wiki.unlock
      lock
      @wiki.body = params[:wiki][:body]
    elsif request.post? and params[:save]
      save
    elsif request.get?
      lock
    end
  end

  def version
    @version = @wiki.versions.find_by_version(params[:id])
  end
  
  def diff
    old_id, new_id = params[:id].split('-')
    @old = @wiki.versions.find_by_version(old_id)
    @new = @wiki.versions.find_by_version(new_id)
    @old_markup = @old.body_html || ''
    @new_markup = @new.body_html || ''
    @difftext = html_diff( @old_markup , @new_markup)

    # output diff html only for ajax requests
    render :text => @difftext if request.xhr?
  end

  def print
    render :layout => "printer-friendly"
  end
  
  def preview
    # not yet
  end
  
  def break_lock
    @wiki.unlock
    redirect_to page_url(@page, :action => 'edit')
  end
    
  protected

  def cancel
    @wiki.unlock(current_user)
    redirect_to page_url(@page, :action => 'show')
  end

  def save
    begin
      @wiki.smart_save!( params[:wiki].merge(:user => current_user) )
      @wiki.unlock(current_user)
      redirect_to page_url(@page, :action => 'show')
    rescue ActiveRecord::StaleObjectError
      # this exception is created by optimistic locking. 
      # it means that @wiki has change since we fetched it from the database
      flash_message_now :error => "locking error. can't save your data, someone else has saved new changes first."
    rescue ErrorMessage => exc
      flash_message_now :error => exc.to_s
    end
  end 

  def lock
    if @wiki.editable_by? current_user
      @locked_for_me = false # not locked for ourselves
      @wiki.lock(Time.now, current_user)
    end
  end
  
  def fetch_wiki
    return true unless @page
    @page.data ||= Wiki.new(:body => 'new page', :page => @page)
    @wiki = @page.data
    @locked_for_me = !@wiki.editable_by?(current_user) if logged_in?
  end
  
  def setup_view
    @show_attach = true
  end
  
end

