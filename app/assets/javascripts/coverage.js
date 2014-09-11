var coverageContext;

$(document).ready(function() {
  ///////   Grade-specific LocationPlan#Show stuff
  coverageContext = new CoverageViewModel();
  ko.applyBindings(coverageContext);

  // Initial load of daygrid
  var d = $('.daygrid').data();
  if(d){
    var chosen_grade_id = d.chosenGradeId;
    load_grade_info(chosen_grade_id);
    colorCalendar();

    var date = $('.daygrid a').first().data().date;
    load_day_info(chosen_grade_id, date);
  }

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
  ///////  END Grade-specific LocationPlan#Show stuff
});

function toCurrency(n, dec){
  if(typeof(dec)==='undefined') dec = 0;
  return '$' + n.toFixed(dec).replace(/\d(?=(\d{3})+(\.\d+)?$)/g, '$&,');
}

function timeOfDay(t){
  if(t == 24 || t == 0){
    return '12:00am';
  }else if(t == 12){
    return '12:00pm';
  }else if(t > 12){
    return (t-12) + ':00pm';
  }else{
    return t + ':00am';
  }
}

function diffClass(num){
  if(num < 1 && num > -1){
    return ""
  }else if( num > 0 ){
    return "bg-danger"
  }else{
    return "bg-success"
  }
}

function diffFormat(num, currency){
  if(typeof(currency)==='undefined') currency = true;
  if(num < 1 && num > -1){
    return "--"
  }else if(num > 0){
    var v = (currency == true) ? toCurrency(num) : Math.round(num);
    return "+" + v
  }else{
    var v = (currency == true) ? toCurrency(-1*num) : Math.round(-1*num);
    return "-" + v
  }
}

function scoreToColor(score){
  if(score && score > 0){
    var v = 80 - Math.min(((score/15 - 30) / 100 * 100), 100);
    return "hsl(" + v + ",90%,90%)"
  } else {
    return 'hsl(0,0%,100%)'
  }
}

function colorCalendar() {
  $('.daygrid td[data-grade-score]').each(function(index, value){
    var t = $(this);
    var s = scoreToColor(t.data().gradeScore);
    t.css("background-color", s);
  });
}

function colorNewDay(date, score) {
  var selector = '.daygrid td[data-date="' + date + '"]';
  $(selector).each(function(index, value){
    var t = $(this);
    var s = scoreToColor(score);
    t.css("background-color", s);
  });
}
