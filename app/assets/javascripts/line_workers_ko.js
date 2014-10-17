var lineWorkerContext;

$(document).ready(function() {
  // Initial load of daygrid
  var grid = $('#line_workers_controller .daygrid');
  var d = grid.data();

  if(d){
    lineWorkerContext = new LineWorkerViewModel();
    ko.applyBindings(lineWorkerContext);

    var chosen_grade_id = d.chosenGradeId;

    var date = grid.find('a').first().data().date;
    load_line_workers_day_info(chosen_grade_id, date);

    grid.find('a').on('click', function(event){
      event.preventDefault();
      var chosen_grade_id = d.chosenGradeId;
      var date  = $(this).data().date;

      load_line_workers_day_info(chosen_grade_id, date);
    });

    $('#location_plan_chosen_grade_id').on('change', function(){
      $(".location_plan_container").hide();
      $(this.form).submit();
    })
  }

});

function load_line_workers_day_info(chosen_grade_id, date) {
  $('#coverage_view').addClass('hidden');
  $('#coverage_view_load').removeClass('hidden');

  var data = {date: date};

  $.ajax( "/grades/" + chosen_grade_id + "/shifts", {data: data} )
    .done(function(data, status, xhr) {
      console.log(data);
      lineWorkerContext.load(data);
      $('#coverage_view').removeClass('hidden');
      $('#coverage_view_load').addClass('hidden');
    })
    .fail(function(xhr, status, error) {
      alert("Load error: " + status + error);
      console.log(xhr.responseText);
    });
}


// Overall viewmodel for a day, along with initial state
function LineWorkerViewModel() {
  var self = this;

  // Editable data
  self.shifts = ko.observableArray([]);
  self.available_times = ko.observableArray([]);
  self.loaded = ko.observable(false);
  self.day_info = ko.observable(null);

  self.prev_date = null;
  self.source    = null;
  self.editable  = null;

  self.load = function(data) {
    if(data.day_info){
      self.day_info(new DayInfo(data.day_info));
    }
    self.chosen_grade_id = data.chosen_grade_id;
    self.source = data.source;
    self.editable = data.editable;

    if(data.day_info){
      self.generateAvailableTimes(data.day_info.open_time, data.day_info.close_time);

      self.shifts.removeAll();
      for (var i = 0; i < data.shifts.length; i++){
        self.shifts.push( new Shift(data.shifts[i]) );
      }

      // We dont' want to set loaded until we've loaded a DAY, not just the grade-wide data
      self.loaded(true);
    }
  };

  self.generateAvailableTimes = function(open_time, close_time) {
    self.available_times.removeAll();
    for(var i = open_time; i <= close_time; i += 1){
      self.available_times.push({num: i, formatted: timeOfDay(i)});
    }
  };

  self.addShift = function() {
    self.shifts.push(new Shift({starts_hour:10, ends_hour: 20}));
  };

  self.removeShift = function(shift) { self.shifts.remove(shift) };

  self.day_hours = ko.computed(function() {
    var total = 0;
    for (var i = 0; i < self.shifts().length; i++)
      total += self.shifts()[i].hours();
    return total;
  });

  self.save = function() {
//    $.ajax("/grades/" + self.chosen_grade_id, {
//      data: ko.toJSON({ date: self.day_info().date(), shifts: self.shifts() }),
//      type: "patch", contentType: "application/json",
//      success: function(result) {
//        load_coverage_day_info(self.chosen_grade_id, self.day_info().date());
//      }
//    });
  };
}
