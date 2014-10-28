var coverageContext;

$(document).ready(function() {
  ///////   Grade-specific LocationPlan#Show stuff
  // Initial load of daygrid
  var grid = $('#location_plans_controller .daygrid');
  var d = grid.data();
  if(d){
    coverageContext = new CoverageViewModel();
    ko.applyBindings(coverageContext);

    var chosen_grade_id = d.chosenGradeId;
    load_grade_info(chosen_grade_id);
    colorCalendar();

    var date = grid.find('a').first().data().date;
    load_coverage_day_info(chosen_grade_id, date);

    grid.find('a').on('click', function(event){
      event.preventDefault();
      var chosen_grade_id = d.chosenGradeId;
      console.log(this);
      var date  = $(this).data().date;

      load_coverage_day_info(chosen_grade_id, date);
    });
  }
  ///////  END Grade-specific LocationPlan#Show stuff
});


// Grade & Coverage display handling

function load_coverage_day_info(chosen_grade_id, date){
  $('#coverage_view').addClass('hidden');
  $('#coverage_view_load').removeClass('hidden');

  load_grade_info(chosen_grade_id, {date: date});

  $.ajax( "/grades/" + chosen_grade_id + "/highcharts", {data: {date: date}} )
    .done(function(data, status, xhr) {
      build_highcharts(data);
    })
    .fail(function(xhr, status, error) {
      inject_coverage_fail('#coverage_hourly', xhr, status, error);
    });

  $.ajax( "/grades/" + chosen_grade_id + "/hourly", {data: {date: date}} )
    .done(function(data, status, xhr) {
      inject_coverage_data('#coverage_hourly', data);
      colorBreakdown();
      $('.table-fixed-header').fixedHeader();
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

// This is scoring the waste/pat so $4 is a great numebr (green) and more than $14 is pretty awful (red)
function scoreToColor(score){
  if(score && score > 0){
    var v = 120 - Math.min( (score-4)*14, 140);
    return "hsl(" + v + ",100%,70%)"
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


function build_highcharts(source){
//
//    console.log("Source");
//    console.log(source);

//    var stack = {
//      data: [],
//      yAxis: 1,
//      name: "Inefficiency",
//      type: 'column',
//      color: 'rgba(159,194,120,1)',
//      legend: {
//        enabled: false
//      }
//    };

//    $.each(source.stack_data, function(itemNo, item) {
//      var data = {};
//      data.y = parseFloat(item);
//
//      if (data.y > 0.5 ) {
//        data.color = 'rgba(238,225,141,1)'; // Yellow
//      }
//      else if (data.y < 0.5 && data.y > -0.5) {
//        data.color = 'rgba(159,194,120,1)'; //Green
//      }else if (data.y < -0.5 && data.y > source.max_turbo_data[itemNo]){
//        data.color = "rgba(227,165,84,1)"; //Orange
//      }else{
//        data.color = "rgba(178,80,76,1)"; // Red
//      }
//
//      stack.data.push(data);
//    });

  $('#highcharts-container').highcharts({
    chart: {
      type: 'column',
      alignTicks: false
    },
    plotOptions: {
      spline: {
        marker: {
          enabled: false
        }
      },
      line: {
        marker: {
          enabled: false
        }
      },
      column: {
        states: {
          hover: {
            brightness: 0.25
          }
        }
      },
      area: {
        stacking: 'normal',
//          lineColor: '#666666',
//          lineWidth: 1,
        marker: { enabled: false }
      }
    },
    tooltip: {
      shared: true,
      style: {
        padding: 12,
        fontWeight: 'bold',
        fontSize: '14px'
      },
      headerFormat: '{point.key}<br>'
    },
    title: {
      text: 'Schedule Efficiency'
    },
    yAxis: [{
      min: 0,
      allowDecimals: false,
      title: {text: "People"}
//        gridLineWidth: 0
    }],
//        plotBands: [{
//          from: 0.5,
//          to: 6,
//          color: 'rgba(238,225,141,0.1)', //Yellow
//          label: {
//            text: 'Slack'
//          }
//        }, {
//          from: 0.5,
//          to: -0.5,
//          color: 'rgba(159,194,120,0.2)',
//          label: {
//            text: ''
//          }
//        }, {
//          from: -0.5,
//          to: -2.0,
//          color: 'rgba(227,165,84,0.1)',  //Orange
//          label: {
//            text: 'Turbo'
//          }
//        }, {
//          from: -2.0,
//          to: -6.0,
//          color: 'rgba(178,80,76,0.1)', //Red
//          label: {
//            text: 'Queue'
//          }
//        }]
    xAxis: {
      tickInterval: 2,
      categories: source.x_axis,
      labels: {
        overflow: 'justify'
      }
    },
    credits: {
      enabled: false
    },
    series: [
      {
        name: "Slack",
        data: source.slack_data,
        color: 'rgba(238,225,141,1)', //Yellow
        type: 'area'
      }, {
        name: "Turbo",
        data: source.turbo_data,
        color: 'rgba(227,165,84,1)',  //Orange
        type: 'area'
      }, {
        name: "Comfortably Seen",
        data: source.seen_normal_data,
        color: 'rgba(159,194,120,1)', // Green
        type: 'area'
      }, {
        name: 'Waiting',
        data: source.waiting_data,
        type: 'line',
        color: 'rgba(178,80,76,1)', //Red
      }, {
        name: 'Visitors',
        data: source.visits_data,
        type: 'line',
        color: 'rgba(135,118,194,1)' // Purple
      }, {
        name: "Queue",
        data: source.queue_data,
        color: 'rgba(178,80,76,1)', //Red
        type: 'column'
//          color: 'rgba(98,161,194,1)' // Blue
      }, {
//          name: "Normal Rate",
//          data: source.normal_data,
//          type: 'line',
//          color: 'rgba(238,225,141,1)', //Yellow
////          yAxis: 1,
//          dashStyle: 'Dash'
//        }, {
        name: "Max Rate",
        data: source.max_data,
        type: 'line',
        color: 'rgba(227,165,84,0.5)',  //Orange
//          yAxis: 1,
        dashStyle: 'Dash'
      }
    ]
  });
}
