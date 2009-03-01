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

  def image_list
    style = "height:64px;width:64px"
    if @images.any?
      items = @images.collect do |asset|
        urls = %['#{asset.thumbnail(:small).url}', '#{asset.thumbnail(:medium).url}', '#{asset.thumbnail(:large).url}', '#{asset.url}']
        insert_text = %{'!' + [#{urls}][$('image_size').value] + '!' + ($('image_link').checked ? ':#{asset.url}' : '')}
        function = %[insertAtCursor('wiki_body',#{insert_text})]
        img = thumbnail_img_tag(asset, :small, :scale => '64x64')
        link_to_function(img, function, :class => 'thumbnail', :title => asset.filename, :style => style)
      end
      content_tag :div, items, :class => 'swatch_list'
    end
  end

  def image_button_for_editor()
    text = "<img src='/images/textile-editor/img.png'/>"
    spinner = spinner('image', :show => true)
    on_click = remote_function(
      :loading => replace_html('markdown_image_button', spinner),
      :complete => replace_html('markdown_image_button', ''),
      :url => page_xurl(@page,:action => 'show_image_popup'))
    "function img_button_clicked() { #{on_click} }"
  end

  def locked_for_me?(section = :all)
    if @wiki and logged_in?
      !@wiki.editable_by?(current_user, section)
    else
      false
    end
  end

end

