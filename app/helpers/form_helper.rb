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

