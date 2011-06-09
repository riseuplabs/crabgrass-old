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

// $('upload_button').observe('click', startProgressBar);

function startProgressBar(button) {
  $('progress').show();

  //add iframe and set form target to this iframe
  $$("body").first().insert({bottom: "<iframe name='progressFrame' style='display:none; width:0; height:0; position: absolute; top:30000px;'></iframe>"});    
  button.up('form').writeAttribute("target", "progressFrame");

  button.up('form').submit();

  //update the progress bar
  var uuid = $('X-Progress-ID').value;
  new PeriodicalExecuter(
    function(){
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
          }
        })
      }
    },2);

  return false; 
}
