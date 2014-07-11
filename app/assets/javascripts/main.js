var coverageContext;

$(document).ready(function() {
  $('.dropdown-toggle').dropdown();
  $('.chosen-select').chosen();
  $('[data-toggle="tooltip"]').tooltip();

  $('[data-behaviour~=datepicker]').datepicker({"format": "yyyy-mm-dd", "weekStart": 0, "autoclose": true});

  $(".form_autoselector").on('change', function(){
    $(this.form).submit();
  });

  $(".select-all").on('click', function(e){
    e.preventDefault();
    $(this).closest('fieldset').find(':checkbox').prop( "checked", true );
  });

  $(".select-none").on('click', function(e){
    e.preventDefault();
    $(this).closest('fieldset').find(':checkbox').prop( "checked", false);
  });
});

function load_day_info(chosen_grade_id, date){
  $('#coverage_view').addClass('hidden');
  $('#coverage_view_load').removeClass('hidden');

  load_grade_info(chosen_grade_id, {date: date});

  $.ajax( "/grades/" + chosen_grade_id + "/hourly", {data: {date: date}} )
      .done(function(data, status, xhr) {
        inject_coverage_data('#coverage_hourly', data);
      })
      .fail(function(xhr, status, error) {
        inject_coverage_fail('#coverage_hourly', xhr, status, error);
      });
}

// A wrapper function that can include or NOT include the date if we want to load just the grade-overview data
function load_grade_info(chosen_grade_id, data){
  $.ajax( "/grades/" + chosen_grade_id, {data: data} )
      .done(function(data, status, xhr) {
        coverageContext.load(data);
        $('#coverage_view').removeClass('hidden');
        $('#coverage_view_load').addClass('hidden');
      })
      .fail(function(xhr, status, error) {
        alert("Load error: " + status + error);
        console.log(xhr.responseText);
      });
}

function inject_coverage_data(selector, data){
  $(selector).removeClass('hidden').html(data);
  $(selector + "_load").addClass('hidden');
}

function inject_coverage_fail(selector, xhr, status, error){
  $(selector).removeClass('hidden').text("ERROR: " + status + " - " + error);
  $(selector + "_load").addClass('hidden');
  console.log(xhr.responseText);
}
