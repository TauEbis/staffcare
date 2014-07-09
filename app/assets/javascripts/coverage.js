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

function diffFormat(num){
  if(num < 1 && num > -1){
    return ""
  }else if(num > 0){
    return "+" + Math.round(num)
  }else{
    return Math.round(num)
  }
}

// Class to represent a row in the list of all shifts for a day
function Shift(starts, ends) {
  var self = this;
  self.starts = ko.observable(starts);
  self.ends = ko.observable(ends);
  self.hours = ko.computed(function(){
    return self.ends() - self.starts();
  });
  self.formatted = ko.computed(function(){
    return timeOfDay(self.ends()) + " - " + timeOfDay(self.starts());
  });
}

function Points(data) {
  var self = this;
  self.total       = ko.observable(data.total);
  self.md_sat      = ko.observable(data.md_sat);
  self.patient_sat = ko.observable(data.patient_sat);
  self.cost        = ko.observable(data.cost);
}

function DiffPoints(oldp, newp){
  return new Points({
    total:       newp.total() - oldp.total(),
    md_sat:      newp.md_sat() - oldp.md_sat(),
    patient_sat: newp.patient_sat() - oldp.patient_sat(),
    cost:        newp.cost() - oldp.cost()
  });
}

function DayInfo(data) {
  var self = this;

  self.open_time = ko.observable(data.open_time);
  self.close_time = ko.observable(data.close_time);

  self.formatted_date = ko.observable(data.formatted_date);
  self.date = ko.observable(data.date);
}

// Overall viewmodel for a day, along with initial state
function CoverageViewModel() {
  var self = this;

  // Editable data
  self.shifts = ko.observableArray([]);
  self.available_times = ko.observableArray([]);
  self.loaded = ko.observable(false);
  self.day_info = ko.observable(null);

  self.day_points = ko.observable(null);
  self.grade_points = ko.observable(null);
  self.grade_hours  = ko.observable(0);

  // When an update for the SAME day is processed,
  // Then we'll store the diffs here
  self.diff_day_points = ko.observable(null);
  self.diff_grade_points = ko.observable(null);
  self.diff_grade_hours  = ko.observable(null);

  self.prev_date = null;
  self.source    = null;
  self.editable  = null;

  self.load = function(data) {
    console.log(data);

    if(data.day_info.date == self.prev_date){
      self.diff_day_points(   DiffPoints(self.day_points(),   new Points(data.day_points)));
      self.diff_grade_points( DiffPoints(self.grade_points(), new Points(data.grade_points)));
      self.diff_grade_hours(  data.grade_hours - self.grade_hours() );
    }else{
      self.diff_day_points(  null);
      self.diff_grade_points(null);
      self.diff_grade_hours( null);
    }

    self.chosen_grade_id = data.chosen_grade_id;
    self.source = data.source;
    self.editable = data.editable;

    self.day_info(new DayInfo(data.day_info));
    self.day_points(new Points(data.day_points));
    self.grade_points(new Points(data.grade_points));
    self.grade_hours(data.grade_hours);
    self.prev_date = data.day_info.date;

    self.generateAvailableTimes(data.day_info.open_time, data.day_info.close_time);

    self.shifts.removeAll();
    for (var i = 0; i < data.shifts.length; i++){
      self.shifts.push( new Shift(data.shifts[i][0], data.shifts[i][1]) );
    }

    self.loaded(true);
  }

  self.generateAvailableTimes = function(open_time, close_time) {
    self.available_times.removeAll();
    for(var i = open_time; i <= close_time; i += 1){
      self.available_times.push({num: i, formatted: timeOfDay(i)});
    }
  }

  self.addShift = function() {
    self.shifts.push(new Shift(10,20));
  };

  self.removeShift = function(shift) { self.shifts.remove(shift) };

  self.day_hours = ko.computed(function() {
    var total = 0;
    for (var i = 0; i < self.shifts().length; i++)
      total += self.shifts()[i].hours();
    return total;
  });

  self.save = function() {
    $.ajax("/grades/" + self.chosen_grade_id, {
      data: ko.toJSON({ date: self.day_info().date(), shifts: self.shifts() }),
      type: "patch", contentType: "application/json",
      success: function(result) {
        load_day_info(self.chosen_grade_id, self.day_info().date());
      }
    });
  };
}
