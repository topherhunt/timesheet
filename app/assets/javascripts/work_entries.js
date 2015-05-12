$(function(){

  $('.stop-work-entry').click(function(e){
    e.preventDefault();
    var button = $(this);
    var path = button.attr('href');

    button.hide();
    button.after('<span class="loading-gif"></span>');

    $.ajax({
      type: 'PATCH',
      url: path,
      success: function(data){
        if (data.success) {
          button.parents('td').html('<strong>'+data.duration+'</strong> hrs');
        }
      }
    })
  });

  $('.mark-billed-work-entry').click(function(e){
    e.preventDefault();
    var button = $(this);
    var path = button.attr('href');

    button.siblings('.text-warning').hide();
    button.hide();
    button.after('<span class="loading-gif"></span>');

    $.ajax({
      type: 'PATCH',
      url: path,
      success: function(data){
        if (data.success) {
          button.siblings('.loading-gif').hide();
          button.parent().html('<span class="text-success">billed</span>');
        }
      }
    });
  });

  $('.delete-work-entry').click(function(e){
    e.preventDefault();
    var button = $(this);
    var path = button.attr('href');

    if (! confirm("Really delete this entry?")) { return; }

    button.hide().after('<span class="loading-gif"></span>');

    $.ajax({
      type: 'DELETE',
      url: path,
      success: function(data){
        if (data.success) {
          button.parents('tr').remove();
        }
      }
    });
  });

});