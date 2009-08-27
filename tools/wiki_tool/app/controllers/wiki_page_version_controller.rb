class WikiPageVersionController < BasePageController
  include ControllerExtension::WikiRenderer

  stylesheet 'wiki_edit'
  #javascript 'wiki_edit'
  helper :wiki, :wiki_page
  permissions :wiki_page_version

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
    raise ErrorMessage.new('version not found') unless version
    @wiki.body = version.body
    @wiki.lock(Time.zone.now, current_user)
    render :template => 'wiki_page/edit'
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
    unless @wiki.nil? or @wiki.editable_by?(current_user)
      @title_addendum = render_to_string(:partial => 'locked_notice')
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
