// Knockout specific parts of Coverage management

// Class to represent a row in the list of all shifts for a day
function Shift(shift_info) {
  var self = this;
  self.id = shift_info.id;
  self.date   = ko.observable(shift_info.date);
  self.starts = ko.observable(shift_info.starts_hour);
  self.ends = ko.observable(shift_info.ends_hour);
  self.position = ko.observable(shift_info.position_name);
  self.position_key = ko.observable(shift_info.position_key);

  self.hours = ko.computed(function(){
    return self.ends() - self.starts();
  });
  self.formatted = ko.computed(function(){
    return timeOfDay(self.ends()) + " - " + timeOfDay(self.starts());
  });

  self.position_name = ko.computed(function(){
    return self.position();
  });

  self.shift_bar_width = ko.computed(function(){
    return (self.hours() * 30) + "px";
  });

  self.shift_bar_offset = ko.computed(function(){
    return (self.starts() - 8) * 30 + "px";
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

function Letters(data) {
  var self = this;
  self.total       = ko.observable(data.total);
  self.md_sat      = ko.observable(data.md_sat);
  self.patient_sat = ko.observable(data.patient_sat);
  self.cost        = ko.observable(data.cost);
}

function OptDiffs(data) {
  var self = this;
  self.total       = ko.observable(data.total);
  self.md_sat      = ko.observable(data.md_sat);
  self.patient_sat = ko.observable(data.patient_sat);
  self.cost        = ko.observable(data.cost);
  self.hours       = ko.observable(data.hours);
}

function MonthStats(data) {
  var self = this;
  self.wait_time       = ko.observable(data.wait_time.toFixed(0));
  self.work_rate       = ko.observable(data.work_rate.toFixed(2));
  self.wasted_time     = ko.observable(data.wasted_time.toFixed(0));
  self.pen_per_pat     = ko.observable(toCurrency(data.pen_per_pat, 0));
  self.wages           = ko.observable(toCurrency(data.wages));
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
  self.day_letters = ko.observable(null);
  self.grade_letters = ko.observable(null);
  self.day_opt_diff = ko.observable(null);
  self.grade_opt_diff = ko.observable(null);
  self.grade_points = ko.observable(null);
  self.grade_hours  = ko.observable(0);
  self.wages = ko.observable(0);
  self.total_wait = ko.observable(0);
  self.work_rate = ko.observable(0);
  self.time_wasted = ko.observable(0);
  self.pat_waste = ko.observable(0);
  self.month_stats = ko.observable(null);

  // When an update for the SAME day is processed,
  // Then we'll store the diffs here
  self.diff_day_points = ko.observable(null);
  self.diff_grade_points = ko.observable(null);
  self.diff_grade_hours  = ko.observable(null);

  self.prev_date = null;
  self.source    = null;
  self.editable  = null;

  self.load = function(data) {
//    console.log(data);

    if(data.day_info){

      console.log(data);

      if(data.day_info.date == self.prev_date){
        self.diff_day_points(   DiffPoints(self.day_points(),   new Points(data.day_points)));
        self.diff_grade_points( DiffPoints(self.grade_points(), new Points(data.grade_points)));
        self.diff_grade_hours(  data.grade_hours - self.grade_hours() );
      }else{
        self.diff_day_points(   null);
        self.diff_grade_points( null);
        self.diff_grade_hours(  null);
      }

      self.day_info(new DayInfo(data.day_info));
      self.day_points(new Points(data.day_points));
      self.day_letters(new Letters(data.day_letters));
      self.day_opt_diff(new OptDiffs(data.opt_diff));
      self.prev_date = data.day_info.date;
    }

    self.grade_opt_diff(new OptDiffs(data.grade_opt_diff) );
    self.grade_letters(new Letters(data.grade_letters));
    self.chosen_grade_id = data.chosen_grade_id;
    self.source = data.source;
    self.editable = data.editable;

    self.month_stats(new MonthStats(data.month_stats));
    self.grade_points(new Points(data.grade_points));
    self.grade_hours(data.grade_hours);



    if(data.day_info){
      self.generateAvailableTimes(data.day_info.open_time, data.day_info.close_time);

      self.shifts.removeAll();
      for (var i = 0; i < data.shifts.length; i++){
        self.shifts.push( new Shift(data.shifts[i]) );
      }

      self.wages(toCurrency(data.wages));
      self.total_wait(data.total_wait.toFixed(0));
      self.work_rate(data.work_rate.toFixed(2));
      self.time_wasted(data.time_wasted.toFixed(0));
      self.pat_waste( toCurrency(data.day_points.total / data.visits , 0) );

      colorNewDay(data.day_info.date, data.day_points.total / data.visits ); // coloring based on waste per patient

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
    self.shifts.push(new Shift({starts_hour:10, ends_hour: 20, position_key: 'md', position_name: 'Physician'}));
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
        load_coverage_day_info(self.chosen_grade_id, self.day_info().date());
      }
    });
  };
}
