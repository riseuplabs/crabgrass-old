module WikiPageHelper

  def locked_error_message
    if @locked_for_me
      msgs = [
        'This wiki is currently locked by %s' % @wiki.locked_by.display_name,
        'You will not be able to save this page'
      ]
      flash_message_now :title => 'Page Locked', :error => msgs
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

end

