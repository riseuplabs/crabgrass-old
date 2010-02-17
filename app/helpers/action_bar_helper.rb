module ActionBarHelper

  def action_bar_submit_mark_function(as)
    "$('mark_as').value = '#{as}';$('mark_form').onsubmit()"
  end

  # view_options is a hash where each is a value to be submitted with the form
  # each value of the hash is the i18n key for the text to show
  def action_bar_view_filter_select(settings)
    options_array = []
    settings[:view].try.each do |view|
      text = I18n.t(view[:translation]).capitalize

      # ex: options_hash["My Watched Pages"] = "watched"
      # we do not use a hash here because it does not preserve order.
      # ex: options_array[["My Watched Pages", "watched],...]"
      options_array.push([text, view[:name].to_s])
    end

    # the first one in the settings list should be selected if no view param given
    selected = params[:view].blank? ? settings[:view].try.first.try[:name].to_s : params[:view]
    options = options_for_select(options_array, selected)
    select_tag 'view_filter_select', options
  end

  # return a form that contains a generated action bar and other content defined by user
  # type - controller name symbol like :pages or :messages which determines
  # mark_path - POST form to this url (ex: /messages/mark)
  # settings - hash which describes what actions are available in the action bar
  # &block - the extra stuff inside the form like a list of items with checkboxes for example
  def action_bar_form(mark_path, settings, &block)
    data_content = capture(&block)

    # _method hidden field is not needed for the ajax form, but can be used if
    # form is submitted without ajax
    form_contents = %Q[
      #{hidden_field_tag('_method', 'put')}
      #{hidden_field_tag('as', '', :id => 'mark_as')}
      #{data_content}
    ]

    form_remote_tag(:url => mark_path, :method => 'put', :update => 'main-content-full',
                    :html => { :id => 'mark_form' }, :loading => show_spinner('mark_as'),
                    :complete => hide_spinner('mark_as')) {concat(form_contents)}

  end
end
