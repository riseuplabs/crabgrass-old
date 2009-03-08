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

function new_recipient()  {
    // serialize Form
 
    // build Ajax Request
    var params = $('recipient_name').serialize() + "&" + $('recipient[access]').serialize();
    new Ajax.Request('/base_page/participation/new_recipient', {asynchronous:true, evalScripts:true, parameters:params, method: 'post'});
}