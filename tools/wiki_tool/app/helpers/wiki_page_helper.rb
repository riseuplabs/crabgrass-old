module WikiPageHelper

  def may_destroy_wiki_version?
    current_user.may?(:admin, @page)
  end

  def may_revert_wiki_version?
    current_user.may?(:edit, @page)
  end

  def locked_error_message
    if locked_for_me?
      user_id = @wiki.locked_by_id
      user = User.find_by_id user_id
      display_name = user ? user.display_name : 'unknown'
      msgs = [
        'This wiki is currently locked by :user'[:wiki_locked] % {:user => display_name},
        'You will not be able to save this page'[:wont_be_able_to_save]
      ]
      flash_message_now :title => 'Page Locked'[:page_locked_header], :error => msgs
    end
  end

  def load_lasted_change_diff
   javascript_tag(
     remote_function(
       :update => 'wiki_html',
       :url => page_xurl(@page, :action => 'diff', :controller => 'version', :id => ("%d-%d" % [@last_seen.version, @wiki.version]))
     )
   )
  end

  def locked_for_me?(section = :all)
    if @wiki and logged_in?
      !@wiki.editable_by?(current_user, section)
    else
      false
    end
  end

  def decorate_with_edit_links
    url = page_xurl(@page, :action => 'edit_inline', :id => '_change_me_')
    opts = {:url => url}

    if @heading_with_form
      opts[:confirm] = "Any unsaved text will be lost. Are you sure?"[:wiki_lost_text_confirmation]
    end

    link = link_to_remote_icon('pencil', opts, :class => 'edit', :title => 'Edit This Section'[:wiki_section_edit], :id => '_change_me__edit_link')
    link.gsub!('"','\"')

    javascript_tag %Q[decorate_wiki_edit_links("#{link}")]
  end

end

