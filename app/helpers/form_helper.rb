#
# globally useful helpers for form elements.
#
#
module FormHelper


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

end

