function Position(data, visits, starts_hour, ends_hour) {
  var self = this
    , distribute = function(visits) {
        var hourly_patients = {};

        for(var hour=starts_hour, i=0; hour < ends_hour; hour++, i+=2) {
          var active_shifts = [];

          // visits are a collection of patients per half hour.
          // Every 2 items must be added to represent an hour of patients
          // TODO: ensure there are no odd number of items
          //       as this will introduce errors in calculation
          hourly_patients[hour] = visits[i] + visits[i+1];

          self.shifts().forEach(function(shift, index) {
            if(shift.covers(hour)) { active_shifts.push(index); }
          });

          console.log("visits", visits);
          console.log("hourly_patients", hourly_patients);
          console.log("active_shifts", active_shifts);

          active_shifts.forEach(function(id, _) {
            self.shifts()[id].patient_load
              .push( hourly_patients[hour]/active_shifts.length );

            console.log("patient_loads", self.shifts()[id].patient_load());
            console.log("patients_per_hour", self.shifts()[id].patients_per_hour());
          });
        }

      }
    , subscribe = function(shift) {
        shift.starts.subscribe(function(_) { distribute(visits) });
        shift.ends.subscribe(function(_) { distribute(visits) });

        return shift;
      }
    , unsubscribe = function(shift) {
      // Memory leak unless we unsubscribe.
      // This seems to be a concern of the Shift
//      shift.starts.dispose();
//      shift.ends.dispose();

        return shift;
      }
  ;

  self.name        = data.name;
  self.key         = data.key;
  self.hourly_rate = data.hourly_rate;
  self.visits      = visits;

  self.shifts = ko.observableArray(
    $.map(data.shifts, function(shift, _){ return subscribe( new Shift(shift) ); } )
  );
  distribute(visits);

  self.hours = ko.computed(function() {
    var sum = 0;

    self.shifts().forEach(function(shift, index) {
      sum += shift.hours();
    });

    return Number( sum );
  });

  self.cost = ko.computed(function() {
    return "$" + Number( self.hourly_rate * self.hours() );
  });
  self.addShift = function(position) {
    self.shifts.push(
      subscribe(
        new Shift({starts_hour: starts_hour, ends_hour: ends_hour, position_key: position.key})
      )
    );
    distribute(visits);
  };

  self.removeShift = function(shift) {
    self.shifts.remove( unsubscribe( shift ) );
    distribute(visits);
  };
};

function Shift(data) {
  var self   = this
  ;

  self.id     = ko.observable(data.id);
  self.date   = ko.observable(data.date);
  self.ends   = ko.observable(data.ends_hour);
  self.starts = ko.observable(data.starts_hour);
  self.position_key      = ko.observable(data.position_key);
  self.patient_load      = ko.observableArray([]);
  self.patients_per_hour = ko.computed(function() {
    var sum = 0;

    for( var i = 0; i < self.patient_load().length; i++ ){
      sum += self.patient_load()[i];
    }

    //TODO: test for divide by 0 errors
    return Number( (sum / self.patient_load().length).toFixed(1) );
  });

  self.hours = ko.computed(function(){
    return self.ends() - self.starts();
  });

  self.formatted = ko.computed(function(){
  //TODO: usage of timeOfDay should be removed as it is not a concern of the shift
    return timeOfDay(self.ends()) + " - " + timeOfDay(self.starts());
  });

  self.shift_bar_width = ko.computed(function(){
    //TODO: usage of shift_bar_width should be removed as it is not a concern of the shift
    var hourly_bar_width = 41;

    return (self.hours() * hourly_bar_width) + "px";
  });

  self.shift_bar_offset = ko.computed(function(){
    //TODO: usage of shift_bar_offset should be removed as it is not a concern of the shift
    var opens = 8 // this is very brittle. Should be coming from the Grade open time.
      , hourly_bar_width = 41
    ;

    return ((self.starts() - opens) * hourly_bar_width) + "px";
  });

  self.covers = function(hour) {
    var covers = false;

    for(var _hour = self.starts(); _hour < self.ends(); _hour++) {
      if(hour === _hour) { covers = true; }
    }
    return covers;
  };
};

// Analysis is all the summed info about a time period.  This could be a day, the whole month,
// or even the whole month across multiple locations
function Analysis(data) {
  var self = this;
  self.points  = ko.observable(new Score(data.points));
  self.letters = ko.observable(new Score(data.letters));
  self.stats   = ko.observable(new Stats(data.stats));
}

function Stats(data) {
  var self = this;
  self.wait_time       = ko.observable(data.wait_time.toFixed(0));
  self.work_rate       = ko.observable(data.work_rate.toFixed(2));
  self.wasted_time     = ko.observable(data.wasted_time.toFixed(0));
  self.pen_per_pat     = ko.observable(toCurrency(data.pen_per_pat, 0));
  self.wages           = ko.observable(toCurrency(data.wages));
}

function Score(data) {
  var self = this;
  self.hours       = ko.observable(data.hours);
  self.total       = ko.observable(data.total);
  self.md_sat      = ko.observable(data.md_sat);
  self.patient_sat = ko.observable(data.patient_sat);
  self.cost        = ko.observable(data.cost);
}

function Grade(data) {
  var self = this;
  self.id = ko.observable(data.id);
  self.source = ko.observable(data.source);
  self.editable = ko.observable(data.editable);
  self.optimizer = ko.observable(data.optimizer);
  self.analysis = ko.observable(new Analysis(data.analysis));
}

// Extra metadata for just an individual day
function DayInfo(data){
  var self = this;
  self.open_time = ko.observable(data.open_time);
  self.close_time = ko.observable(data.close_time);

  self.formatted_date = ko.observable(data.formatted_date);
  self.date = ko.observable(data.date);

  self.analysis = ko.observable(new Analysis(data.analysis));
}

var position_keys = ['md', 'scribe', 'ma', 'pcr', 'xray', 'am', 'manager'];

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
    var visits = data.visits || [];

    self.grade(new Grade(data.grade));

    if(!data.day_info){ return; }

    if(data.day_info.date == self.prev_date){
      self.prev_grade( self.grade() );
      self.prev_day_info( self.day_info() );
    }else{
      self.prev_grade( null );
      self.prev_day_info( null );
    }

    self.day_info(new DayInfo(data.day_info));
    self.prev_date = data.day_info.date;

    self.generateAvailableTimes(data.day_info.open_time, data.day_info.close_time);

    self.positions($.map(data.positions, function(position, _){

      return new Position(position, visits, data.day_info.open_time, data.day_info.close_time);
    }));
    self.positions( self.positions.sort( function(a, b){ return position_keys.indexOf(a.key) - position_keys.indexOf(b.key) }) );

    colorNewDay(data.day_info.date, data.day_info.analysis.stats.pen_per_pat ); // coloring based on waste per patient

    // We don't want to set loaded until we've loaded a DAY, not just the grade-wide data
    self.loaded(true);
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

// does this ever get used? Me thinks not.
  self.save = function() {
    var shifts = jQuery.map(self.positions(), function(position, i){ // Actually a flatmap. Stupid jQuery
      return position.shifts();
    });

    var gid = self.grade().id();

  //TODO: Remove. Not being used.
    $.ajax("/grades/" + gid, {
      data: ko.toJSON({ date: self.day_info().date(), shifts: shifts}),
      type: "patch", contentType: "application/json",
      success: function(result) {
        load_coverage_day_info(gid, self.day_info().date());
      }
    });
  };
}
