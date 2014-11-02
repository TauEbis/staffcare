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

// Stats is all the summed info about a time period.  This could be a day, the whole month,
// or even the whole month across multiple locations
function Stats(data) {
  var self = this;
  self.points          = ko.observable(new Score(data.points));
  self.letters         = ko.observable(new Score(data.letters));

  self.wait_time       = ko.observable(data.wait_time.toFixed(0));
  self.work_rate       = ko.observable(data.work_rate.toFixed(2));
  self.wasted_time     = ko.observable(data.wasted_time.toFixed(0));
  self.pen_per_pat     = ko.observable(toCurrency(data.pen_per_pat, 0));
  self.wages           = ko.observable(toCurrency(data.wages));
}

function Grade(data) {
  var self = this;
  self.id = data.id;
  self.source = data.source;
  self.editable = data.editable;
  self.optimizer = data.optimizer;
  self.stats = ko.observable(new Stats(data.stats));
}

// Extra metadata for just an individual day
function DayInfo(data){
  var self = this;
  self.open_time = ko.observable(data.open_time);
  self.close_time = ko.observable(data.close_time);

  self.formatted_date = ko.observable(data.formatted_date);
  self.date = ko.observable(data.date);

  self.stats = ko.observable(new Stats(data.stats));
}


function Score(data) {
  var self = this;
  self.hours       = ko.observable(data.hours);
  self.total       = ko.observable(data.total);
  self.md_sat      = ko.observable(data.md_sat);
  self.patient_sat = ko.observable(data.patient_sat);
  self.cost        = ko.observable(data.cost);
}
//
//function OptDiffs(data) {
//  var self = this;
//  self.total       = ko.observable(data.total);
//  self.md_sat      = ko.observable(data.md_sat);
//  self.patient_sat = ko.observable(data.patient_sat);
//  self.cost        = ko.observable(data.cost);
//  self.hours       = ko.observable(data.hours);
//}

//function MonthStats(data) {
//  var self = this;
//  self.wait_time       = ko.observable(data.wait_time.toFixed(0));
//  self.work_rate       = ko.observable(data.work_rate.toFixed(2));
//  self.wasted_time     = ko.observable(data.wasted_time.toFixed(0));
//  self.pen_per_pat     = ko.observable(toCurrency(data.pen_per_pat, 0));
//  self.wages           = ko.observable(toCurrency(data.wages));
//}
//
//function DayInfo(data) {
//  var self = this;
//
//  self.open_time = ko.observable(data.open_time);
//  self.close_time = ko.observable(data.close_time);
//
//  self.formatted_date = ko.observable(data.formatted_date);
//  self.date = ko.observable(data.date);
//}

// Overall viewmodel for a day, along with initial state
function CoverageViewModel() {
  var self = this;

  // Editable data
  self.grade  = ko.observable(null);
  self.day_info = ko.observable(null);
  self.shifts = ko.observableArray([]);

  self.available_times = ko.observableArray([]);
  self.loaded = ko.observable(false);

  // When an update for the SAME day is processed,
  // Then we'll store the diffs here
  self.prev_grade    = ko.observable(null);
  self.prev_day_info = ko.observable(null);
  self.prev_date = null;

  self.load = function(data) {
//    console.log(data);

    if(data.day_info){

      if(data.day_info.date == self.prev_date){
        self.prev_grade( self.grade() );
        self.prev_day_info( self.day_info() );
      }else{
        self.prev_grade( null );
        self.prev_day_info( null );
      }

      self.day_info(new DayInfo(data.day_info));
      self.prev_date = data.day_info.date;
    }

    self.grade(new Grade(data.grade));

    if(data.day_info){
      self.generateAvailableTimes(data.day_info.open_time, data.day_info.close_time);

      self.shifts.removeAll();
      for (var i = 0; i < data.shifts.length; i++){
        self.shifts.push( new Shift(data.shifts[i]) );
      }

      colorNewDay(data.day_info.date, data.day_info.stats.points.total / data.visits ); // coloring based on waste per patient

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
