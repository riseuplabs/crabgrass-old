class WikiPageController < BasePageController
  include ControllerExtension::WikiRenderer
  include ControllerExtension::WikiImagePopup

  helper_method :current_locked_section, :desired_locked_section, :has_some_locked_section?,
                  :has_wrong_locked_section?, :has_desired_locked_section?, :editing_a_section?

  stylesheet 'wiki_edit'
  javascript :wiki, :action => :edit

  helper :wiki # for wiki toolbar stuff
  permissions 'wiki_page'

  before_filter :setup_wiki_rendering
  before_filter :find_last_seen, :only => :show

  # if we have some section locked, but we don't need it. we should drop the lock
  before_filter :release_old_locked_section!, :only => [:edit, :update]
  ##
  ## ACCESS: public or :view
  ##

  def show
    if @wiki.body.empty?
      # we have no body to show, edit instead
      redirect_to_edit
    elsif current_locked_section == :document
      flash_message :info => "You have this wiki locked. If you want to stop editing, click the cancel button."[:view_while_locked_error]
      redirect_to_edit
    elsif current_locked_section
      @editing_section = current_locked_section
      # replace wiki_html with wiki_html + edit form
      # render_edit
    end
  end

  def print
    render :layout => "printer-friendly"
  end

  ##
  ## ACCESS: :edit
  ##

  def edit
    @wiki.unlock!(desired_locked_section, current_user, :break => true) if params[:break_lock]
    acquire_desired_locked_section!
  rescue WikiLockError => exc
    # we couldn't acquire a lock. do nothing here. user will see 'break lock' button
  ensure
    @editing_section = desired_locked_section
  end


  def update
    # setup the updated data from visual editor if needed
    params[:wiki][:body] = html_to_greencloth(params[:wiki][:body_html]) if params[:wiki][:body_html].any?

    if params[:cancel]
      update_cancel
      return
    end

    if params[:break_lock]
      update_break_lock
      return
    end

    # get the lock we need if we don't have it
    acquire_desired_locked_section!

    # no version checking for sections
    version = (current_locked_section == :document) ? params[:wiki][:version] : nil

    # do the update (will either create a new version or will update the latest version with new data)
    @wiki.update_section!(current_locked_section, current_user, version, params[:wiki][:body])

    current_user.updated(@page)
    # everything went nicely
    # drop whatever lock we have
    release_current_locked_section!

    # no errors - show the updated wiki
    @update_successful = true
    @editing_section = nil

    require 'ruby-debug';debugger;1-1
    if request.xhr?
      render :action => 'edit'
    else
      redirect_to_show
    end
  rescue WikiLockError => exc
  rescue ActiveRecord::StaleObjectError => exc
    # this exception is created by optimistic locking.
    # it means that @wiki has change since we fetched it from the database
    flash_message_now :error => "locking error. can't save your data, someone else has saved new changes first."[:locking_error]
  rescue ErrorMessage => exc
    flash_message_now :error => exc.to_s
  ensure
    unless @update_successful
      @wiki.body = params[:wiki][:body]
      @editing_section = desired_locked_section
      render :action => 'edit'
    end
  end


  # Handle the switch between Greencloth wiki a editor and Wysiwyg wiki editor
  def update_editors
    return if @wiki.locked_by_id != current_user.id || !@wiki.editable_by?(current_user)
    render :json => update_editor_data(:editor => params[:editor], :wiki => params[:wiki])
  end

  ##
  ## INLINE WIKI EDITING
  ##
  #
  # def edit_inline
  #   heading = params[:id]
  #   @wiki.lock(Time.now, current_user, heading)
  #   update_inline_html(heading)
  # rescue WikiLockError
  #   @locker = User.find_by_id @wiki.locked_by_id(heading)
  #   @locker ||= User.new :login => 'unknown'
  #   @wiki_inline_error = 'This wiki is currently locked by :user'[:wiki_locked] % {:user => @locker.display_name}
  #   update_inline_html(heading)
  # end
  #
  # def save_inline
  #   heading = params[:id]
  #   if params[:save]
  #     body = params[:body]
  #     greencloth = GreenCloth.new(@wiki.body)
  #     greencloth.set_text_for_heading(heading, body)
  #     @wiki.smart_save!(:body => greencloth.to_s, :user => current_user, :heading => heading)
  #     current_user.updated(@page)
  #   else
  #     @wiki.unlock(heading) if @wiki.editable_by?(current_user, heading)
  #   end
  #   update_inline_html(@wiki.currently_editing_section(current_user))
  # end

  ##
  ## PROTECTED
  ##

  protected

  # user clicked the 'cancel' button
  # should only be called from update action
  def update_cancel
    # drop whatever lock we have
    release_current_locked_section!
    @update_successful = true

    redirect_to_show
  end

  # user clicked the 'break lock' button on the edit form
  # we will re-render
  def update_break_lock
    @wiki.unlock!(desired_locked_section, current_user, :break => true) if params[:break_lock]
    acquire_desired_locked_section!
    @update_successful = true

    @wiki.body = params[:wiki][:body]
    render :action => 'edit'
  end



  # def update_inline_html(heading)
  #   render :update do |page|
  #     page.replace_html(:wiki_html, :partial => 'wiki_html')
  #   end
  # end


  # # Takes some html and a section (defined from heading_start to heading_end)
  # # and replaces the section with the form. This is pretty crude, and might not
  # # work in all cases.
  # def replace_section_with_form(html, heading_start, heading_end, form)
  #   index_start = html.index /<h[1-4](\s+class=["']first["'])?><a name="#{Regexp.escape(heading_start)}">/
  #   if heading_end and index_end = html.index(/<h[1-4]><a name="#{Regexp.escape(heading_end)}">/)
  #     index_end -= 1
  #   else
  #     index_end = -1
  #   end
  #   html[index_start..index_end] = form if index_start
  #   return html
  # end

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
  def render_edit
    # need to switch between inline editor and full page editor
    if request.xhr? or editing_a_section?
      render :action => 'edit.rjs'
    else
      render :action => 'edit.html.erb'
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
    unless @wiki.nil? or @wiki.document_open_for?(current_user)
      @title_addendum = render_to_string(:partial => 'locked_notice')
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
  def editing_a_section?
    @editing_section && @editing_section != :document
  end
end
