$(function(){

  function checkIfTimezoneNeedsUpdating(){
    var detectedTz = detectTz();
    var configuredTz = $('#js-update-tz-banner').data('configured-tz');
    if (configuredTz != detectedTz && alertNotYetDismissed()){
      $('#js-update-tz-link').attr('href', '/users/update?user[time_zone]='+detectedTz);
      $('#js-detected-tz').text(detectedTz);
      $('#js-update-tz-banner').fadeIn();
    }
  }

  function detectTz(){
    return Intl.DateTimeFormat().resolvedOptions().timeZone;
  }

  function alertNotYetDismissed(){
    return !localStorage.getItem("updateTimezoneAlertDismissed");
  }

  $('#js-update-tz-link').click(function(e){
    e.preventDefault();
    $(e.target).replaceWith("Updating...")
    Ajax.call("patch", "/users/1", {
      data: {user: {time_zone: detectTz()}},
      success: function(data){ window.location.reload(); }
    });
  });

  $('#js-dismiss-tz-link').click(function(e){
    e.preventDefault();
    localStorage.setItem("updateTimezoneAlertDismissed", "true");
    $('#js-update-tz-banner').fadeOut();
  });

  if ($('#js-update-tz-banner').length > 0){
    checkIfTimezoneNeedsUpdating();
  }

});
