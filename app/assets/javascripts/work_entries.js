$(function(){

  $('.copy-tooltip').click(function(){
    var text = $(this).attr('tooltip');
    window.prompt("Copy tooltip to clipboard", text);
  });

  $('.mark-billed-work-entry').click(function(e){
    e.preventDefault();
    var button = $(this);

    button.siblings('.text-warning').hide();
    button.hide();
    button.after('<span class="loading-gif"></span>');

    $.ajax({
      type: 'PATCH',
      url:  button.attr('href'),
      data: { work_entry: { is_billed: true } },
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

  $('.js-merge-entry').click(function(e){
    e.preventDefault();
    var button = $(this);
    var entry_id = button.data('entry-id');
    var path = '/work_entries/' + entry_id + '/prior_entry';
    $.ajax({
      type: 'GET',
      url: path,
      success: function(data){
        onPriorEntryDataReceived(button, entry_id, data);
      },
      error: function(xhr){
        console.log('Error making request to '+path+': ', xhr);
        alert('Error merging entries. Please refresh the page and try again.');
      }
    });
  });

  function onPriorEntryDataReceived(button, from_id, data) {
    if (data.billing_status_term) {
      var message = 'The previous entry for project "'+data.project_name+'" and status "'+data.billing_status_term+'" was on '+data.date+' for '+data.duration+' hours. \n\nAre you sure you want to merge this entry into that one?';
      if (! confirm(message)) { return; }

      var path = '/work_entries/merge?from='+from_id+'&to='+data.entry_id;
      $.ajax({
        type: 'POST',
        url: path,
        success: function(){
          button.parents('tr').remove();
        },
        error: function(xhr) {
          console.log('Error making request to '+path+': ', xhr);
          alert('Error merging entries. Please refresh the page and try again.');
        }
      });
    } else if (data.none_found) {
      alert('No previous entry was found with the same project and status.');
    } else {
      console.log('Unable to parse this response. Data: ', data);
      alert('There was an error. Please refresh the page and try again.');
    }
  }

});
