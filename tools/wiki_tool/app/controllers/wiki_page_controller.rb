class WikiPageController < BasePageController
  include ControllerExtension::WikiRenderer
  include ControllerExtension::WikiPopup

  helper_method :current_locked_section, :desired_locked_section, :has_some_locked_section?,
                  :has_wrong_locked_section?, :has_desired_locked_section?, :show_inline_editor?


  stylesheet 'wiki_edit'
  javascript :wiki, :action => :edit

  helper :wiki # for wiki toolbar stuff
  helper_method :save_or_cancel_edit_lock_wiki_error_text

  permissions 'wiki_page'

  before_filter :setup_wiki_rendering
  before_filter :find_last_seen, :only => :show
  before_filter :force_save_or_cancel, :only => [:show, :print]

  before_filter :ensure_desired_locked_section_exists, :only => [:edit, :update]
  # if we have some section locked, but we don't need it. we should drop the lock
  before_filter :release_old_locked_section!, :only => [:edit, :update]

  before_render :setup_title_box

  ##
  ## ACCESS: public or :view
  ##

  def show
    if @wiki.body.empty?
      # we have no body to show, edit instead
      redirect_to_edit
    elsif current_locked_section
      @editing_section = current_locked_section
    end
  end

  def print
    render :layout => "printer-friendly"
  end

  # GET
  # plain - clicked edit tab, section = nil.  render edit ui with tabs and full markup
  # XHR - clicked pencil, section = 'someheading'. replace #wiki_html with inline editor
  def edit
    @editing_section = desired_locked_section

    @wiki.unlock!(desired_locked_section, current_user, :break => true) if params[:break_lock]
    acquire_desired_locked_section!
  rescue WikiLockError => exc
    # we couldn't acquire a lock. do nothing here for document edit. user will see 'break lock' button
    if show_inline_editor?
      @locker = @wiki.locker_of(@editing_section)
      @locker ||= User.new :login => 'unknown'
      @wiki_inline_error = I18n.t(:wiki_is_locked, :user => @locker.display_name)
    end
  rescue ActiveRecord::StaleObjectError => exc
     # this exception is created by optimistic locking.
     # it means that wiki or wiki locks has change since we fetched it from the database
     flash_message_now :error => I18n.t(:locking_error)
  ensure
    render :action => 'update_wiki_html' if show_inline_editor?
  end

  # PUT
  # plain - clicked save/cancel/break lock on edit tab, section = nil. redirect to show on save, render edit on break lock
  # xhr - clicked save/cancel on inline editor, section = 'somesection'.  rjs replace #wiki_html with wiki.body_html
  def update
    # no RESTful routing for now unfortunately
    if request.get?
      redirect_to_show
      return
    end

    @editing_section = desired_locked_section

    # setup the updated data from visual editor if needed
    if params[:wiki]
      params[:wiki][:body] = html_to_greencloth(params[:wiki][:body_html]) if params[:wiki][:body_html].any?
    end

    if params[:break_lock]
      @wiki.unlock!(desired_locked_section, current_user, :break => true) if params[:break_lock]
      acquire_desired_locked_section!
    elsif params[:cancel]
      release_current_locked_section!
      @update_completed = true
    else
      # update wiki body data
      # get the lock we need if we don't have it
      acquire_desired_locked_section!

      # no version checking for sections
      version = (current_locked_section == :document) ? params[:wiki][:version] : nil

      # do the update (will either create a new version or will update the latest version with new data)
      @wiki.update_section!(current_locked_section, current_user, version, params[:wiki][:body])

      current_user.updated(@page)

      # everything went well
      # drop whatever lock we have
      release_current_locked_section!
      # no errors
      @update_completed = true
    end

  rescue WikiLockError => exc
  rescue ActiveRecord::StaleObjectError => exc
    # this exception is created by optimistic locking.
    # it means that wiki or wiki locks has change since we fetched it from the database
    flash_message_now :error => I18n.t(:locking_error)
  rescue ErrorMessage => exc
    flash_message_now :error => exc.to_s
  ensure
    render_update_outcome unless request.get?
  end


  # Handle the switch between Greencloth wiki a editor and Wysiwyg wiki editor
  def update_editors
    return unless @wiki.document_open_for?(current_user)
    render :json => update_editor_data(:editor => params[:editor], :wiki => params[:wiki])
  end

  ##
  ## PROTECTED
  ##
  protected

  def render_update_outcome
    if @update_completed
      @editing_section = nil
    else
      @wiki.body = params[:wiki][:body] if params[:wiki]
      @editing_section = desired_locked_section
    end

    render_or_redirect_to_updated_wiki_html
  end


  # which images should be displayed in the image upload popup
  def image_popup_visible_images
    Asset.visible_to(current_user, @page.group).media_type(:image).most_recent.find(:all, :limit=>20)
  end

  # called during BasePage::create
  def build_page_data
    Wiki.new(:user => current_user, :body => "")
  end

  ### REDIRECTS
  def redirect_to_edit
    redirect_to page_url(@page, :action => 'edit')
  end

  def redirect_to_show
    redirect_to page_url(@page, :action => 'show')
  end

  ### RENDERS
  def render_or_redirect_to_updated_wiki_html
    if request.xhr?
      render :action => 'update_wiki_html'
    elsif @update_completed
      redirect_to_show
    else
      render :action => 'edit'
    end
  end

  ### FILTERS
  def prepare_wiki_body_html
    if current_locked_section and current_locked_section != :document
      @wiki.body_html = body_html_with_form(current_locked_section)
    end
  end
  # called early in filter chain
  def fetch_data
    return true unless @page
    @wiki = @page.wiki
    @wiki_is_blank = @wiki.body.blank?
  end

  def setup_wiki_rendering
    return unless @wiki
    @wiki.render_body_html_proc {|body| render_wiki_html(body, @page.owner_name)}
  end

  def find_last_seen
    if @upart and !@upart.viewed? and @wiki.version > 1
      @last_seen = @wiki.first_version_since( @upart.viewed_at )
    end
  end

  def setup_view
    @show_attach = true
  end

  def setup_title_box
    unless @wiki.nil? or @wiki.document_open_for?(current_user)
      @title_addendum = render_to_string(:partial => 'locked_notice')
      @title_box = '<div id="title" class="page_title shy_parent">%s</div>' % render_to_string(:partial => 'base_page/title/title')
    end
  end

  # if the user has a section locked, redirect them to edit
  def force_save_or_cancel
    if current_locked_section == :document
      flash_message :info => save_or_cancel_edit_lock_wiki_error_text
      redirect_to_edit
    end
  end

  def ensure_desired_locked_section_exists
    begin
      @wiki.get_body_for_section(desired_locked_section)
    rescue Exception => exc
      flash_message_now :error => exc.to_s
      @wiki_inline_error = exc.to_s
      @editing_section = nil
      @update_completed = true
      render_or_redirect_to_updated_wiki_html
      return false
    end
  end

  ### LOCKS
  # if we're trying to update some section, but we have a lock for a different
  # section so we should drop the different section
  def release_old_locked_section!
    release_current_locked_section! if has_wrong_locked_section?
  end

  # unlock the current section we have locked  (if we have something locked)
  def release_current_locked_section!
    @wiki.unlock!(current_locked_section, current_user) if current_locked_section
  end

  # if we're trying to edit or update a particular section, this will try to gain the lock
  # unless we already have it
  def acquire_desired_locked_section!
    @wiki.lock!(desired_locked_section, current_user) unless has_desired_locked_section?
  end

  # returns the section for which which the current_user has a lock (or nil)
  def current_locked_section
    @wiki.section_edited_by(current_user) if logged_in? && @wiki
  end

  # returns the section the current user needs to acquire (trying to update or edit)
  def desired_locked_section
    params[:section] || :document
  end

  # returns true if user has the lock they need to modify the section they want to modify
  def has_desired_locked_section?
    current_locked_section == desired_locked_section
  end

  # returns true only if user has some lock, which happens to be the wrong lock
  def has_wrong_locked_section?
    current_locked_section && (current_locked_section != desired_locked_section)
  end

  # returns true if the user desires to edit some section
  # which is not :document
  def show_inline_editor?
    @editing_section && @editing_section != :document
  end

  ### HELPER METHODS
  def save_or_cancel_edit_lock_wiki_error_text
    I18n.t(:save_or_cancel_edit_lock_wiki_error, {:save_button => I18n.t(:save_button), :cancel_button => I18n.t(:cancel_button)})
  end
end
