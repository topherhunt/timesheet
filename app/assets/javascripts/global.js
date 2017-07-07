$(function(){

  $('.has-tooltip').each(function(){
    var target = $(this);
    target.tooltip({
      placement: target.attr('placement') || 'top',
      title:     target.attr('tooltip'),
      delay:     100
    });
  });

  $('.has-popover').each(function(){
    var target = $(this);
    target.attr('data-content', target.siblings('.popover-content').html());
    target.popover({ html: true });
  });

  $('.reveal-target').click(function(e){
    e.preventDefault();
    $($(this).attr('target')).toggle();
  });

  $('tr.highlight-on-hover').hover(function(){
    $(this).addClass('row-highlight');
  }, function(){
    $(this).removeClass('row-highlight');
  });

  $('.reveal-on-hover').hover(function(){
    $(this).find($(this).attr('target')).show();
  }, function(){
    $(this).find($(this).attr('target')).hide();
  });

});
