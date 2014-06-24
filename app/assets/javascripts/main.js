$(document).ready(function() {
  $('.dropdown-toggle').dropdown();
  $('.chosen-select').chosen();

  $('[data-behaviour~=datepicker]').datepicker({"format": "yyyy-mm-dd", "weekStart": 0, "autoclose": true});

  $(".detail_date").on('change', function(){
    $(this.form).submit();
  });

  $('#coverage_date_form').on('ajax:before', function(event){
    $('#coverage_view').addClass('hidden');
    $('#coverage_view_load').removeClass('hidden');
  })
  .on('ajax:success', function(event, data, xhr, status){
    $('#coverage_view').removeClass('hidden');
    $('#coverage_view_load').addClass('hidden');
    $('#coverage_view').html(data);
  })
  .on('ajax:error', function(event, xhr, status, error){
    $('#coverage_view').removeClass('hidden');
    $('#coverage_view_load').addClass('hidden');
    $('#coverage_view').text("ERROR: " + status + " - " + error);
    console.log(xhr.responseText);
  });
});
