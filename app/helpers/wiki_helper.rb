module WikiHelper

  def wiki_action(action, hash={})
    {:controller => 'wiki', :action => action, :group_id => @group.id,
     :profile_id => (@profile ? @profile.id : nil)}.merge(hash)
  end

  def wiki_edit_link(wiki_id=nil)
    # note: firefox uses layerY, ie uses offsetY
    link_to_remote_with_icon('edit wiki'.t, :icon => 'pencil',
      :url => wiki_action('edit', :wiki_id => wiki_id),
      :with => "'height=' + (event.layerY? event.layerY : event.offsetY)"
    )
  end

  def area_id(wiki)
    'edit_area-%s' % wiki.id
  end

  # this is the textarea were wiki is written
  def wiki_body_id(wiki)
    'wiki_body-%s' % wiki.id
  end

  def wiki_toolbar_id(wiki)
    'markdown_toolbar-%s' % wiki.id
  end

  def image_popup_id(wiki)
    'image_popup-%s' % wiki.id
  end

  def old_version_select_tag(wiki, spinner_id)
    version_labels_values = []
    # [['Version 1', '1'], ['Version 2', '2'],...]
    wiki.versions.each do |version|
      version_labels_values << [wiki_version_label(version), version.version]
    end

    # if we have an old version loaded, we should have that one as the selected one
    # in the options tag. but since we're working with two wikis at once (public and private)
    # the version we're showing is only for one tab and we have to be sure it's for the right wiki
    if @showing_old_version && wiki.versions.include?(@showing_old_version)
      selected_version = @showing_old_version
    else
      selected_version = wiki.versions.last
    end

    select_tag_options = options_for_select(version_labels_values, selected_version.version)
    select_tag_name = 'old_version_select-' + wiki.id.to_s
    select_tag select_tag_name, select_tag_options,
      :onchange => (remote_function(:url => wiki_action('old_version', :wiki_id => wiki.id),
                                      :loading => show_spinner(spinner_id),
                                      :with => "'old_version=' + $('#{select_tag_name}').value",
                                      :confirm => "Any unsaved text will be lost. Are you sure?"[:confirm_load_old_wiki_version]))
  end

  # returns something like 'Version 3 created Fri May 08 12:22:03 UTC 2009 by Blue!'
  def wiki_version_label(version)
    label = :version_number.t % {:version => version.version}
     # add users name
     if version.user_id
       user_name = User.find(version.user_id).name
       label << ' ' << :created_when_by.t % {
         :when => full_time(version.updated_at),
         :user => user_name
       }
     end

     label
  end

  def popup_image_list(wiki)
    style = "height:64px;width:64px"
    if @images.any?
      items = @images.collect do |asset|
        urls = %['#{asset.thumbnail(:small).url}', '#{asset.thumbnail(:medium).url}', '#{asset.thumbnail(:large).url}', '#{asset.url}']
        insert_text = %{'!' + [#{urls}][$('#{'image_size-' + wiki.id.to_s}').value] + '!' + ($('#{'image_link-' + wiki.id.to_s}').checked ? ':#{asset.url}' : '')}
        function = %[insertAtCursor('#{wiki_body_id(wiki)}',#{insert_text})]
        img = thumbnail_img_tag(asset, :small, :scale => '64x64')
        link_to_function(img, function, :class => 'thumbnail', :title => asset.filename, :style => style)
      end
      content_tag :div, items, :class => 'swatch_list'
    end
  end

  def create_wiki_toolbar(wiki)
    body_id = wiki_body_id(wiki)
    toolbar_id = wiki_toolbar_id(wiki)
    image_popup_code = image_popup_code_for_wiki_toolbar(wiki)

    "wiki_edit_add_toolbar('#{body_id}', '#{toolbar_id}', '#{wiki.id.to_s}', function() {#{image_popup_code}});"
  end

  def image_popup_code_for_wiki_toolbar(wiki)
    text = "<img src='/images/textile-editor/img.png'/>"
    spinner = spinner('image', :show => true)
    remote_function(
      :loading => replace_html('markdown_image_button-' + wiki.id.to_s, spinner),
      :complete => replace_html('markdown_image_button-' + wiki.id.to_s, ''),
      :url => image_popup_show_url(wiki))
  end

  def image_popup_upload_url(wiki)
    wiki_action('image_popup_upload', :wiki_id => wiki.id)
  end

  def image_popup_show_url(wiki)
    wiki_action('image_popup_show', :wiki_id => wiki.id)
  end
end
