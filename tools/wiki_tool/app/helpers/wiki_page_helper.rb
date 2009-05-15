module WikiPageHelper

  def locked_error_message
    if @locked_for_me
      msgs = [
        'This wiki is currently locked by :user'[:wiki_locked] % {:user => @wiki.locked_by.display_name},
        'You will not be able to save this page'[:wont_be_able_to_save]
      ]
      flash_message_now :title => 'Page Locked'[:page_locked_header], :error => msgs
    end
  end

  def load_lasted_change_diff
   javascript_tag(
     remote_function(
       :update => 'wiki_html',
       :url => {
         :controller => :wiki_page,
         :action => :diff,
         :page_id => @page.id,
         :id => "%d-%d" % [@last_seen.version, @wiki.version]
       }
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
    ####
    #
    #
    ##### TODO: :confirm leaving alone the existing work
    link = link_to_remote_icon('pencil', {:url => url}, :class => 'edit', :title => 'Edit This Section'[:wiki_section_edit])
    link.gsub!('"','\"')

    # locked_sections = @wiki.edit_locks.select {|heading, attributes| attributes[:locked_by_id] != current_user.id }
    locked_sections = @wiki.locked_sections_not_by(current_user).collect{|s| s == :all ? ':all' : s }.inspect
    # .each do |section|
    #   locked_sections_string << section.inspect
    #   locked_sections_string << ","
    # end
    # locked_sections_string.chop!


    javascript_tag %Q[wiki_edit_decorate_with_edit_links("#{link}", #{locked_sections});]
  end

end

