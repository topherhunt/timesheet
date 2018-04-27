$(function(){

  var helpers = {
    refresh_metric_since: function(){
      if ($('.js-metric-since').val() == "date") {
        $('.js-metric-since-date').show();
      } else {
        $('.js-metric-since-date').hide().val("");
      }
    }
  };

  helpers.refresh_metric_since();
  $('.js-metric-since').change(function(){
    helpers.refresh_metric_since();
  });

});
