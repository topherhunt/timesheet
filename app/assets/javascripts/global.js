$(function(){

  $('.has-tooltip').each(function(){
    var hotspot = $(this);
    hotspot.tooltip({
      placement: hotspot.attr('placement') || 'top',
      title:     hotspot.attr('tooltip'),
      delay:     100
    });
  });

  $('.reveal-target').click(function(e){
    e.preventDefault();
    $($(this).attr('target')).toggle();
  });

  if ($('#keepalive').length > 0){
    function ping(){
      console.log("Sending keepalive ping.");

      $.ajax({
        type: 'GET',
        url:  '/keepalive',
        success: function(data){
          if (data.success){ queue_ping(); }
          else { require_signin(); }
        },
        error: function(){ require_signin(); }
      });
    }

    function queue_ping(){
      setTimeout(function(){ ping(); }, 1000 * 60 * 15);
    }

    function require_signin(){
      window.location = "/users/sign_in";
    }

    queue_ping();
  }

  $('tr.highlight-on-hover').hover(function(){
    $(this).addClass('row-highlight');
  }, function(){
    $(this).removeClass('row-highlight');
  });

});