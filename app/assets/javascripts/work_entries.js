$(function(){

  $('.js-creates-value').click(function(e){
    e.preventDefault();
    var button = $(this);
    var row = button.parents('tr');
    var entry_id = button.data('entry-id');
    var path = '/work_entries/' + entry_id;
    var cur_creates_value = button.data('creates-value');

    $.ajax({
      dataType: 'json',
      type: 'PATCH',
      url: path,
      data: {
        work_entry: {creates_value: !cur_creates_value}
      },
      success: function(data) {
        if (data.success) {
          button.data('creates-value', !cur_creates_value);
          row.find('.js-creates-value-icon').toggle();
          animateUpdatedRow(row);
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
      success: function(data) {
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
    if (data.status) {
      var message = 'The previous "'+data.status+'" entry for project "'+data.project_name+'" was on '+data.started_at_date+' for '+data.duration+' hours. \n\nAre you sure you want to merge this entry into that one?';
      if (! confirm(message)) { return; }

      var to_id = data.entry_id;
      var path = '/work_entries/merge?from='+from_id+'&to='+to_id;
      var to_row = $('tr.js-entry-row[data-entry-id="'+data.entry_id+'"]');

      $.ajax({
        dataType: 'json',
        type: 'POST',
        url: path,
        success: function(data){
          if (data.success) {
            button.parents('tr').remove();
            to_row.find('.js-entry-duration').text(data.new_duration + ' h');
            to_row.find('.js-entry-invoice-notes').text(data.new_invoice_notes);
            animateUpdatedRow(to_row);
          }
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

  function animateUpdatedRow(row) {
    row.css({opacity: '0.25'});
    row.animate({opacity: '1.0'}, 1000);
  }

});
