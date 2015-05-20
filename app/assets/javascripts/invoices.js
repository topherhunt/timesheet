$(function(){

  $('form.new_invoice').find('input, select').click(function(){
    $('#results-div').hide();
    $('#preview-entries-div').empty();
  });

  $('.preview-entries').click(function(){
    $('#preview-entries-div').empty();

    var form = $('form.new_invoice');
    var client_id  = form.find('#invoice_client_id') .val();
    var date_start = form.find('#invoice_date_start').val();
    var date_end   = form.find('#invoice_date_end')  .val();

    if (client_id && date_start && date_end) {
      $('#results-div').show();
      $('.loading').show();

      var url = '/invoices/preview'+
        '?client_id='  +client_id +
        '&date_start=' +date_start+
        '&date_end='   +date_end;

      $.ajax({
        type: 'GET',
        url: url,
        success: function(content){
          if (content.indexOf("preview-div-loaded") > 0) {
            $('#preview-entries-div').html(content);
            $('.loading').hide();
          } else {
            alert("Server returned invalid response.");
          }
        },
        error: function(){
          alert("Failed to connect to server.");
        }
      });
    } else {
      alert("Not all fields are filled in. Please enter a client, start date, and end date.");
    }
  });

});