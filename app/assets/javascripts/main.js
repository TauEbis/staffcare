$(document).ready(function() {
  $('.dropdown-toggle').dropdown();
  $('.chosen-select').chosen();
  $('[data-toggle="tooltip"]').tooltip();

  $('[data-behaviour~=datepicker]').datepicker({"format": "yyyy-mm-dd", "weekStart": 0, "autoclose": true});
  $('[data-behaviour~=monthpicker]').datepicker({"format": "yyyy-mm-01", "viewMode": "months", "minViewMode": "months", "weekStart": 0, "autoclose": true});
  $('[data-behaviour~=weekstartpicker]').datepicker({"format": "yyyy-mm-dd", "weekStart": 0, "autoclose": true, "calendarWeeks": true,
    "daysOfWeekDisabled": [0,1,2,3,4,6] });
  $('[data-behaviour~=weekstoppicker]').datepicker({"format": "yyyy-mm-dd", "weekStart": 0, "autoclose": true, "calendarWeeks": true,
    "daysOfWeekDisabled": [0,1,2,3,5,6] });

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

  $('.pull-down').each(function() {
    $(this).css('margin-top', $(this).parent().height()-$(this).height())
  });

  setSessionTimeout();
});

// Automatic logout functionality

var timer;

function setSessionTimeout() {
  if (typeof timer !== 'undefined') {
    clearTimeout(timer);
  }
  var seconds = $('#timeout').attr('data-timeout-in');
  if (typeof seconds !== 'undefined') {
    timer = setTimeout( 'signOut()', seconds*1000 + 15);
  }
}

function signOut() {
  var sign_out_path = $('#timeout').attr('data-sign-out-path');
  $.ajax({url:sign_out_path,type:"DELETE",async:true,success:function(){
    clearHistory();
  }})
}

function clearHistory()
{
     var backlen = history.length;
     history.go(-backlen);
     window.location.href = '/users/sign_in'
}

function colorBreakdown() {
  $('td.dollar').filter(function(){
    return $(this).html() > 80
  }).addClass("bg-danger").prepend("$");

  $('td.dollar').filter(function(){
    return $(this).html() > 40 && $(this).html() <= 80
  }).addClass('bg-warning').prepend("$");

  $('td.dollar').filter(function(){
    return $(this).html() <= 40
  }).addClass('bg-warning').prepend("$");

  $('td.people').filter(function(){
    return $(this).html() > 2
  }).addClass("bg-danger");

  $('td.people').filter(function(){
    return $(this).html() > 1 && $(this).html() <= 2
  }).addClass('bg-warning');
}


