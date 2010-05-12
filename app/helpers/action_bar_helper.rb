module ActionBarHelper

  # return params[:view] or the default view (which is the first name in view settings)
  def action_bar_current_view_name(settings)
    params[:view].blank? ? settings[:view].try.first.try[:name].to_s : params[:view]
  end

  def action_bar_submit_mark_function(as)
    "$('mark_as').value = '#{as}';$('mark_form').onsubmit()"
  end

  # view_options is a hash where each is a value to be submitted with the form
  # each value of the hash is the i18n key for the text to show
  def action_bar_view_filter_select(settings)
    options_array = []
    settings[:view].try.each do |view|
      text = I18n.t(view[:translation])

      # ex: options_hash["My Watched Pages"] = "watched"
      # we do not use a hash here because it does not preserve order.
      # ex: options_array[["My Watched Pages", "watched],...]"
      options_array.push([text, view[:name].to_s])
    end

    # the first one in the settings list should be selected if no view param given
    options = options_for_select(options_array, action_bar_current_view_name(settings))
    select_tag 'view_filter_select', options
  end

  # render the action bar with a form and hidden fields.
  # The following options can be set:
  # :select - List of selectors for the checkboxes
  # :mark - List of flags to mark the selected pages as
  # :view - List of views to select from
  # :view_base_path - request other views based on this path (ex: /pages/all)
  #
  # The Lists are Arrays of Hashes with :name and :translation keys used.
  # The content the action bar acts upon should be passed as a block.
  def action_bar(options)
    render(:partial => 'common/action_bar', :locals => {:settings => options})
  end

  # return a form that wraps the other content defined by user
  # mark_path - POST form to this url (ex: /messages/mark)
  # settings - hash which describes what actions are available in the action bar
  # &block - the extra stuff inside the form (see request/_main_content.html.haml for example)
  def action_bar_form(mark_path, &block)
    form_remote_tag(:url => mark_path,
      :method => 'put',
      :update => 'main-content-full',
      :html => { :id => 'mark_form' },
      :loading => show_spinner('mark_as'),
      :complete => hide_spinner('mark_as'), &block)
  end

end
