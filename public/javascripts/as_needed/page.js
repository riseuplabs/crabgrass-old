function recipient_checked(checkbox, recipient_name) {
  if (checkbox.checked) {
    $(recipient_name + '_selected').show()
  } else {
    $(recipient_name + '_selected').hide()
  }
  $$('.recipient_checkbox_' + recipient_name).each( function(cb) {
    cb.checked = checkbox.checked
  });
}

