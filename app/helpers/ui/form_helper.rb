##
## globally useful helpers for form elements.
##

module UI::FormHelper

  def option_empty(label='')
    %(<option value=''>#{label}</option>)
  end

  # DROP DOWN LIST
  #
  # use this as:
  #
  # drop_down("Title", {"Option 1" => some_place_path, "Option 2" => "js: alert('hello')"}, optionally_index_for_selected_option)
  #
  # <label for="select_id">Title</label>
  # <select id="select_id">
  #   <option value="/some/place">Option 1</option>
  #   <option value="alert('hello')">Option 2</option>
  # </select>
  #
  # Actions happen on the onchange event
  #
  def drop_down(select_title, items, selected_index = 0)

    select_id = "select_#{select_title.gsub(/[^a-zA-Z]+/, '')}"

    text_label = content_tag(:label, I18n.t(:view_label), :for => select_id) if !select_title.nil? && !select_title.blank?

    current_index = 0
    options = items.map do |title, perform|
      selected = selected_index == current_index ? {:selected => "selected"} : {}
      current_index += 1
      perform = url_for(perform) if perform.is_a?(Hash)
      option_id = "option_#{title.gsub(/[^a-zA-Z]+/, '')}"
      value = drop_down_action(perform)
      content_tag :option, title, {:value => value, :id => option_id}.merge(selected)
    end.join("\n")

    content_tag(:div, text_label + select_tag(select_id, options, :onchange => "javascript: eval(this.options[this.selectedIndex].value)"), :id => "pages_view")
  end

  def drop_down_action(perform)
    if perform.match(/^js\:/)
      perform.gsub(/^js\:/, '')
    else
      "window.location = '#{perform}';"
    end
  end

  def options_for_my_groups(selected=nil)
    options_for_select([['','']] + current_user.groups.sort_by{|g|g.name}.to_select(:name), selected)
  end

  def options_for_language(selected=nil)
    selected ||= session[:language_code].to_s
    options_array = I18n.available_locales.collect {|locale| [I18n.language_for_locale(locale).try.name, locale.to_s]}
    options_for_select(options_array, selected)
  end

  #
  # add some radio buttons, using a similar api to select and select_tag
  #
  # choices: array of choices in the form [[label, id],[label, id]]
  #
  def radio_buttons_tag(name, choices, options={})
    join = options.delete(:separator) || ' '
    selected = options.delete(:selected) || choices.first[1]
    html = []
    choices.each do |label, id|
      checked = selected == id
      html << radio_button_tag(name, id, checked) +
              label_tag("%s_%s" % [name, id], label)
    end
    html.join(join)
  end

  # return javascript code to confirm leaving the page if textarea
  # has been modified. the user can click 'Cancel' and continue editing the textarea
  # or click 'Ok' and the unsaved data in the textarea will be lost.
  #
  # saving_selectors is a collection of selectors for elements (buttons, links)
  # which can be clicked to leave the page without the warning.
  #
  # if the user clicks an element maching a saving_selector, the confirmation dialog
  # will get disabled until the page is reloaded
  def confirm_discarding_text_area(text_area_id, saving_selectors, message = nil)
    message ||= I18n.t(:confirm_discarding_text_area, :cancel => I18n.t(:cancel))

    %Q[confirmDiscardingTextArea("#{text_area_id}", "#{message}", #{saving_selectors.inspect})]
  end

end
