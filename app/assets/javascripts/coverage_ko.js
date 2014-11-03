// Knockout specific parts of Coverage management

// Class to represent a row in the list of all shifts for a day
function Shift(data) {
  var self = this;
  self.id = ko.observable(data.id);
  self.date   = ko.observable(data.date);
  self.starts = ko.observable(data.starts_hour);
  self.ends = ko.observable(data.ends_hour);
  self.position_key = ko.observable(data.position_key);

  self.hours = ko.computed(function(){
    return self.ends() - self.starts();
  });
  self.formatted = ko.computed(function(){
    return timeOfDay(self.ends()) + " - " + timeOfDay(self.starts());
  });

  self.shift_bar_width = ko.computed(function(){
    return (self.hours() * 51) + "px";
  });

  self.shift_bar_offset = ko.computed(function(){
    return (self.starts() - 8) * 51 + "px";
  });

}

function Position(data) {
  var self = this;
  self.name = ko.observable(data.name);
  self.key  = ko.observable(data.key);
  self.shifts = ko.observableArray($.map(data.shifts, function(elem, i){
    return new Shift(elem);
  }));

  self.addShift = function(position) {
    self.shifts.push(new Shift({starts_hour: 10, ends_hour: 20, position_key: position.key}));
  };

  self.removeShift = function(shift) { self.shifts.remove(shift) };
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
  self.id = ko.observable(data.id);
  self.source = ko.observable(data.source);
  self.editable = ko.observable(data.editable);
  self.optimizer = ko.observable(data.optimizer);
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

var position_keys = ['md', 'scribe', 'ma', 'xray', 'pcr', 'manager', 'am'];

// Overall viewmodel for a day, along with initial state
function CoverageViewModel() {
  var self = this;

  // Editable data
  self.grade  = ko.observable(null);
  self.day_info = ko.observable(null);
  self.positions = ko.observableArray([]);

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
      self.positions = ko.observableArray($.map(data.positions, function(elem, i){ return new Position(elem); }));

      colorNewDay(data.day_info.date, data.day_info.stats.points.total / data.visits ); // coloring based on waste per patient

      // We dont' want to set loaded until we've loaded a DAY, not just the grade-wide data
      self.loaded(true);
    }
  };

  self.position_name = function(index) {
    return position_keys[index];
  };

  self.generateAvailableTimes = function(open_time, close_time) {
    self.available_times.removeAll();
    for(var i = open_time; i <= close_time; i += 1){
      self.available_times.push({num: i, formatted: timeOfDay(i)});
    }
  };

  self.save = function() {
    var shifts = jQuery.map(self.positions(), function(position, i){ // Actually a flatmap. Stupid jQuery
      return position.shifts();
    });

    var gid = self.grade().id();

    $.ajax("/grades/" + gid, {
      data: ko.toJSON({ date: self.day_info().date(), shifts: shifts}),
      type: "patch", contentType: "application/json",
      success: function(result) {
        load_coverage_day_info(gid, self.day_info().date());
      }
    });
  };
}
