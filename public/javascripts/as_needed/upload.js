// if this is the iframe
// reload the parent
Event.observe(window, 'load',
  function() {
    try
    {
    if (self.parent.frames.length != 0)
    self.parent.location=document.location;
    }
    catch (Exception) {}
  }
);

function styleUpload() {
  var styled = $('add_file_field').previous('.styled-upload');
  var real = styled.down('.real-upload');
  if (real == undefined) { return; }
  styled.insert('<div class="fake-upload">' +
      '<input type="submit"></input>' +
      '<input type="text" class="small_icon" name="fakeupload" readonly></input>' +
    '</div>')
  var fake = styled.down('.fake-upload');
  var text = fake.down('.small_icon');
  text.writeAttribute('size', real.readAttribute('size'));
  fake.observe('click', selectFile);
  real.observe('change', updateFakeUpload);
  fake.show();
  real.hide();
}

function selectFile(event){
  var el = event.element()
  fake = el.hasClassName('fake-upload') ? el: el.up('.fake-upload');
  real = fake.previous('.real-upload');
  // IE does not support the event approach below
  try {
    real.click();
  }
  // Chrome does not support .click() method
  catch(e) {
    var ev = document.createEvent("MouseEvents");
    ev.initMouseEvent("click", true, true, window,0, 0, 0, 0, 0, false, false, false, false, 0, null);
    real.dispatchEvent(event);
  }
  event.stop();
}

function updateFakeUpload(event) {
  real = event.element();
  var fake_text = real.next('.fake-upload').down('input.small_icon')
  fake_text.value = real.value.split('\\').pop().split('/').pop();
  fake_text.addClassName('filled');
  fake_text.addClassName(classNameForFile(fake_text.value));
}

function classNameForFile(filename) {
  var ext = filename.split('.').pop().toLowerCase();
  switch(ext) {
    case 'tar': return 'mime_archive_16';
    case 'zip': return 'mime_archive_16';
    case 'gz': return 'mime_archive_16';
    case 'gzip': return 'mime_archive_16';
    case 'wav': return 'mime_audio_16';
    case 'mp3': return 'mime_audio_16';
    case 'ogg': return 'mime_audio_16';
    case 'bin': return 'mime_binary_16';
    case 'doc': return 'mime_doc_16';
    case 'html': return 'mime_html_16';
    case 'htm': return 'mime_html_16';
    case 'jpg': return 'mime_image_16';
    case 'jpeg': return 'mime_image_16';
    case 'png': return 'mime_image_16';
    case 'gif': return 'mime_image_16';
    case 'xl': return 'mime_msexcel_16';
    case 'ppt': return 'mime_mspowerpoint_16';
    case 'pps': return 'mime_mspowerpoint_16';
    case 'docx': return 'mime_msword_16';
    case 'odt': return 'mime_oo_document_16';
    case 'odp': return 'mime_oo_presentation_16';
    case 'ods': return 'mime_oo_spreadsheet_16';
    case 'pdf': return 'mime_pdf_16';
    case 'rtf': return 'mime_rtf_16';
    case 'svg': return 'mime_vector_16';
    case 'avi': return 'mime_video_16';
    case 'ogm': return 'mime_video_16';
    case 'mpeg': return 'mime_video_16';
    default: return 'mime_default_16';
  }
}

function startProgressBar(button) {
  $('progress').show();

  //add iframe and set form target to this iframe
  $$("body").first().insert({bottom: "<iframe name='progressFrame' style='display:none; width:0; height:0; position: absolute; top:30000px;'></iframe>"});    
  button.up('form').writeAttribute("target", "progressFrame");

  button.up('form').submit();

  //update the progress bar
  var uuid = $('X-Progress-ID').value;
  new PeriodicalExecuter(
    function(pe){
      if(Ajax.activeRequestCount == 0){
        new Ajax.Request("/progress",{
          method: 'get',
          parameters: 'X-Progress-ID=' + uuid,
          onSuccess: function(xhr){
            // stop this thing if the response is blank 
            // likely the upload failed or server doesn't support it
            // and it goes on forever
            if(xhr.responseText == "") {
	            pe.stop();
            }
            var upload = xhr.responseText.evalJSON();
            if(upload.state == 'uploading'){
              upload.percent = Math.floor((upload.received / upload.size) * 100);
							var processing = '';
							if (upload.percent == 100) {
							  processing = " - processing...";
							}
              $('bar').setStyle({width: upload.percent + "%"});
              $('bar').update(upload.percent + "%" + processing);
            }
            if(upload.state == 'done'){
              $('bar').setStyle({width: "100%"});
              $('bar').update("100 % - done");
              pe.stop();
            }
          }
        })
      }
    },1);

  return false; 
}
