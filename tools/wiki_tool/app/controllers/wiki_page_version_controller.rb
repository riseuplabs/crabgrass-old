class WikiPageVersionController < BasePageController
  include ControllerExtension::WikiRenderer

  stylesheet 'wiki_edit'
  #javascript 'wiki_edit'
  helper :wiki, :wiki_page
  permissions :wiki_page_version

  before_filter :force_save_or_cancel, :only => [:show, :list, :diff]

  ##
  ## ACCESS: public or :view
  ##

  def show
    @version = @wiki.versions.find_by_version(params[:id])
  end

  def next
    redirect_to page_url(@page, :action => 'version-show', :id => get_jump(:next))
  end

  def previous
    redirect_to page_url(@page, :action => 'version-show', :id => get_jump(:prev))
  end

  def list
  end

  def destroy
    @version = @wiki.versions.find(params[:id])
    @version.destroy
    redirect_to page_url(@page, :action => 'version-list')
  rescue Exception => exc
    render :text => 'could not find version'
  end

  def diff
    old_id, new_id = params[:id].split('-')
    @old = @wiki.versions.find_by_version(old_id)
    @new = @wiki.versions.find_by_version(new_id)

    if @old and @new
      @old_markup = @old.body_html || ''
      @new_markup = @new.body_html || ''
      @difftext = HTMLDiff.diff( @old_markup , @new_markup)

      # output diff html only for ajax requests
      render :text => @difftext if request.xhr?
    else
      render :text => 'versions not found'
    end
  end

  def revert
    version = @wiki.versions.find_by_version params[:id]
    raise_error('version not found') unless version

    @wiki.revert_to_version(version.version, current_user)
    # blow away all locks
    @wiki.unlock!(:document, current_user, :break => true)
    redirect_to page_url(@page, :action => 'show')
  rescue Exception => exc
    flash_message_now :exception => exc
  end

  ##
  ## PROTECTED
  ##

  protected

  # called early in filter chain
  def fetch_data
    return true unless @page
    @wiki = @page.data
  end

  # before filter
  def setup_view
    @show_attach = true
    unless @wiki.nil? or @wiki.document_open_for?(current_user)
      @title_addendum = render_to_string(:partial => 'wiki_page/locked_notice')
    end
  end

  # if the user has a section locked, redirect them to edit
  def force_save_or_cancel
    if logged_in? and @wiki and @wiki.section_edited_by(current_user) == :document
      flash_message :info => I18n.t(:save_or_cancel_edit_lock_wiki_error,
                                        :save_button => I18n.t(:save_button),
                                        :cancel_button => I18n.t(:cancel_button))
      redirect_to page_url(@page, :action => 'edit')
    end
  end

  # gets the next or previous version number
  def get_jump(direction)
    version = @wiki.versions.find_by_version(params[:id])
    if direction == :next
      version = version.next
      version = @wiki.versions.earliest unless version
    elsif direction == :prev
      version = version.previous
      version = @wiki.versions.latest unless version
    end
    return version.version
  end

end
