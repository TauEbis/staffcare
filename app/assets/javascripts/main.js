$(document).ready(function() {
  $(".select2").select2();
  $('[data-behaviour~=datepicker]').datepicker({"format": "yyyy-mm-dd", "weekStart": 0, "autoclose": true});
});
