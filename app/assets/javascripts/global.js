$(function(){

  $('.has-tooltip').each(function(){
    var hotspot = $(this);
    hotspot.tooltip({
      placement: hotspot.attr('placement') || 'top',
      title:     hotspot.attr('tooltip'),
      delay:     100
    });
  });

});