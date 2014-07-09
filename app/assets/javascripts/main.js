var coverageContext;

$(document).ready(function() {
  $('.dropdown-toggle').dropdown();
  $('.chosen-select').chosen();

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

  coverageContext = new CoverageViewModel();
  ko.applyBindings(coverageContext);

  $('.daygrid a').on('click', function(event){
    event.preventDefault();

    var chosen_grade_id = $('.daygrid').data().chosenGradeId;
    var date  = $(this).data().date;

    load_day_info(chosen_grade_id, date);
  });

  $('#location_plan_chosen_grade_id').on('change', function(){
    $(".location_plan_container").hide();
    $(this.form).submit();
  })
});

function load_day_info(chosen_grade_id, date){
  $('#coverage_view').addClass('hidden');
  $('#coverage_view_load').removeClass('hidden');

  $.ajax( "/grades/" + chosen_grade_id, {data: {date: date}} )
      .done(function(data, status, xhr) {
        coverageContext.load(data);
        $('#coverage_view').removeClass('hidden');
        $('#coverage_view_load').addClass('hidden');
      })
      .fail(function(xhr, status, error) {
        alert("Load error" + status + error);
        console.log(xhr.responseText);
//          inject_coverage_fail('#coverage_view', xhr, status, error);
      });

  $.ajax( "/grades/" + chosen_grade_id + "/hourly", {data: {date: date}} )
      .done(function(data, status, xhr) {
        inject_coverage_data('#coverage_hourly', data);
      })
      .fail(function(xhr, status, error) {
        inject_coverage_fail('#coverage_hourly', xhr, status, error);
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
