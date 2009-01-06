class WikiPageController < BasePageController

  include ControllerExtension::WikiRenderer
  
  stylesheet 'wiki_edit', :action => :edit
  javascript 'wiki_edit', :action => :edit

  ##
  ## ACCESS: no restriction
  ##

  def create
    @page_class = WikiPage
    if params[:cancel]
      return redirect_to(create_page_url(nil, :group => params[:group]))
    elsif request.post?
      begin
        @page = create_new_page!(@page_class)
        @page.update_attribute(:data, Wiki.create(:user => current_user))
        return redirect_to(page_url(@page, :action => 'edit'))
      rescue Exception => exc
        @page = exc.record
        flash_message_now :exception => exc
      end
    end
    render :template => 'base_page/create'
  end

  ##
  ## ACCESS: public or :view
  ##

  def show
    if @wiki.body.empty?
      redirect_to page_url(@page,:action=>'edit')
      return
    elsif @upart and !@upart.viewed? and @wiki.version > 1
      @last_seen = @wiki.first_since( @upart.viewed_at )
    end
    # render if needed
    @wiki.render_html{|body| render_wiki_html(body, @page.owner_name)}
  end

  def version
    @version = @wiki.versions.find_by_version(params[:id])
  end

  def versions
  end
  
  def diff
    # require 'ruby-debug'; debugger
    old_id, new_id = params[:id].split('-')
    @old = @wiki.versions.find_by_version(old_id)
    @old.render_html{|body| render_wiki_html(body, @page.owner_name)} # render if needed

    @new = @wiki.versions.find_by_version(new_id)
    @new.render_html{|body| render_wiki_html(body, @page.owner_name)} # render if needed

    @old_markup = @old.body_html || ''
    @new_markup = @new.body_html || ''
    @difftext = HTMLDiff.diff( @old_markup , @new_markup)

    # output diff html only for ajax requests
    render :text => @difftext if request.xhr?
  end

  def print
    # render if needed
    @wiki.render_html{|body| render_wiki_html(body, @page.owner_name)}
    render :layout => "printer-friendly"
  end

  ##
  ## ACCESS: :edit
  ##

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

  # TODO: make post only    
  def break_lock
    @wiki.unlock
    redirect_to page_url(@page, :action => 'edit')
  end
  
  # xhr only
  def show_image_popup
    @images = Asset.visible_to(current_user, @page.group).media_type(:image).most_recent.find(:all, :limit=>20)
    render(:update) do |page| 
      page.replace 'image_popup', :partial => 'image_popup'
    end
  end

  # upload image via xhr
  # response goes to an iframe, so requires responds_to_parent
  def upload
    asset = Asset.build params[:asset]
    asset.parent_page = @page
    asset.save
    @images = Asset.visible_to(current_user, @page.group).media_type(:image).most_recent.find(:all, :limit=>20)
    responds_to_parent do
      render(:update) do |page|
        page.replace 'image_popup', :partial => 'image_popup'
      end
    end
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
      current_user.updated(@page)
      #@page.save
      redirect_to page_url(@page, :action => 'show')
    rescue ActiveRecord::StaleObjectError
      # this exception is created by optimistic locking. 
      # it means that @wiki has change since we fetched it from the database
      flash_message_now :error => "locking error. can't save your data, someone else has saved new changes first."[:locking_error]
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
  
  # called early in filter chain
  def fetch_data
    return true unless @page
    @wiki = @page.data
    @locked_for_me = !@wiki.editable_by?(current_user) if logged_in?
  end
  
  def setup_view
    @show_attach = true
    if @locked_for_me
      @title_addendum = render_to_string(:partial => 'locked_notice')
    end
  end

  def authorized?
    if @page
      if %w(show print diff version versions).include? params[:action]
        @page.public? or current_user.may?(:view, @page)
      elsif %w(edit break_lock upload).include? params[:action]
        current_user.may?(:edit, @page)
      else
        current_user.may?(:admin, @page)
      end
    else
      true
    end
  end
  
end

