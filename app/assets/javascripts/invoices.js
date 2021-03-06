$(function(){

  $('form.new_invoice').find('input, select').click(function(){
    $('#results-div').hide();
    $('#preview-entries-div').empty();
  });

  $('.preview-entries').click(function(){
    $('#preview-entries-div').empty();

    var form = $('form.new_invoice');
    var project_id  = form.find('#invoice_project_id').val();
    var date_start = form.find('#invoice_date_start').val();
    var date_end   = form.find('#invoice_date_end')  .val();

    if (project_id && date_start && date_end) {
      $('#results-div').show();
      $('.loading').show();

      var url = '/invoices/preview'+
        '?project_id=' +project_id+
        '&date_start=' +date_start+
        '&date_end='   +date_end;

      $.ajax({
        type: 'GET',
        url: url,
        success: function(content){
          if (content.indexOf("preview-div-loaded") > 0) {
            $('#preview-entries-div').html(content);
            $('.loading').hide();

            // Re-initialize tooltips for any new contents
            $('.has-tooltip').each(function(){
              var hotspot = $(this);
              hotspot.tooltip({
                placement: hotspot.attr('placement') || 'top',
                title:     hotspot.attr('tooltip'),
                delay:     100
              });
            });
          } else {
            alert("Server returned invalid response.");
          }
        },
        error: function(){
          alert("Failed to connect to server.");
        }
      });
    } else {
      alert("Not all fields are filled in. Please select a project, start date, and end date.");
    }
  });

});
