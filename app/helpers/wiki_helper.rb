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
    '%s_edit_area' % wiki.id
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
end
