Ajax = {};
Ajax.call = function(method, url, args){
  var error = function(){
    console.error("AJAX call failed: "+method+" "+url);
    if (args.error) { args.error(); }
  };

  $.ajax({
    method: method,
    url: url,
    dataType: "json",
    data: args.data,
    success: function(data){
      if (data.success){
        if (args.success) { args.success(data); }
      } else {
        error();
      }
    },
    error: error
  });
};
