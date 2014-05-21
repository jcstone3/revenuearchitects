$(".surveys.question").ready(function() {
  cookies_string = document.cookie.split(';');
  str = 'popup_model';
  var popup_present;
  for (var j=0; j<cookies_string.length; j++) {
    if (cookies_string[j].match(str)){
     popup_present = cookies_string[j];
    }
  }
  if (popup_present!='undefined'){
    if (popup_present.split('=')[1]=='true'){
      $('#popup-notice').modal('show')
      $('#popup-notice').css("z-index","1050");
    }
    else{
      $('#popup-notice').modal('hide')
      $('#popup-notice').css("z-index","0");
    }
  }

  $("#prevent_popup").live('change', function(){
    var checked;
    if ($(this).is(':checked')) {
      checked = false;
    } else {
      checked = true;
    }

    $.ajax({
      url: '/surveys/prevent_popup',
      type: 'POST',
      data: {"checked": checked}
    });
  });

});
