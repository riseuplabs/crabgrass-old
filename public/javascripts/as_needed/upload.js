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

function observeRealUpload() {
  $$('.real-upload').each( function (upload) {
    upload.observe('change', updateFakeUpload);
  });
}

function updateFakeUpload(event) {
  real = event.element();
  var fake = real.form.fakeupload;
  fake.value = real.value.split('\\').pop().split('/').pop();
  fake.addClassName('filled');
  fake.addClassName(fake.value.split('.').pop().toLowerCase());
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
            var upload = xhr.responseText.evalJSON();
            if(upload.state == 'uploading'){
              upload.percent = Math.floor((upload.received / upload.size) * 100);
              $('bar').setStyle({width: upload.percent + "%"});
              $('bar').update(upload.percent + "%");
            }
            if(upload.state == 'done'){
              $('bar').setStyle({width: "100%"});
              $('bar').update("100 % - done");
              pe.stop();
            }
          }
        })
      }
    },2);

  return false; 
}
