module ActionBarHelper

  def action_bar_submit_mark_function(as)
    "$('mark_as').value = '#{as}';this.up('form#mark_form').onsubmit()"
  end

  # view_options is a hash where each is a value to be submitted with the form
  # each value of the hash is the i18n key for the text to show
  def action_bar_view_filter_select(settings)
    options_hash = {}
    settings[:view].try.each do |view|
      text = I18n.t(view[:translation]).capitalize

      # ex: options_hash["My Watched Pages"] = "watched"
      options_hash[text] = view[:name].to_s
    end

    # the first one in the settings list should be selected if no view param given
    selected = params[:view].blank? ? settings[:view].try.first.try[:name].to_s : params[:view]
    options = options_for_select(options_hash, selected)
    select_tag 'view_filter_select', options
  end

  # return a form that contains a generated action bar and other content defined by user
  # type - controller name symbol like :pages or :messages which determines
  # mark_path - POST form to this url (ex: /messages/mark)
  # view_path - GET from this url when view dropdown changes (ex: /messages)
  # settings - hash which describes what actions are available in the action bar
  # &block - the extra stuff inside the form like a list of items with checkboxes for example
  def action_bar_form(mark_path, view_path, settings, &block)
    data_content = capture(&block)
    action_bar_content = settings.blank? ? "" : capture do
      render :partial => 'common/action_bar',
        :locals => {:mark_path => mark_path, :view_path => view_path, :settings => settings}
    end

    form_contents = %Q[
      #{hidden_field_tag('as', '', :id => 'mark_as')}
      #{action_bar_content}
      #{data_content}
    ]

    form_remote_tag(:url => mark_path, :method => 'put', :update => 'main-content-full',
                    :html => { :id => 'mark_form' }, :loading => show_spinner('mark_as'),
                    :complete => hide_spinner('mark_as')) {concat(form_contents)}

  end
end
