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

function DayInfo(data) {
  var self = this;
  self.total  = ko.observable(data.total);
  self.md_sat = ko.observable(data.md_sat);
  self.patient_sat = ko.observable(data.patient_sat);
  self.cost   = ko.observable(data.cost);

  self.open_time = ko.observable(data.open_time);
  self.close_time = ko.observable(data.close_time);

  self.formatted_date = ko.observable(data.formatted_date);
  self.date = ko.observable(data.date);
  self.source = ko.observable(data.source);
}

// Overall viewmodel for a day, along with initial state
function CoverageViewModel() {
  var self = this;

  // Editable data
  self.shifts = ko.observableArray([]);
  self.available_times = ko.observableArray([]);
  self.loaded = ko.observable(false);
  self.day_info = ko.observable(null);

  self.load = function(data) {
    console.log(data);
    self.location_plan_id = data.location_plan_id;
    self.day_info(new DayInfo(data));
    self.generateAvailableTimes(data.open_time, data.close_time);

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
    $.ajax("/grades/" + self.location_plan_id, {
      data: ko.toJSON({ date: self.day_info().date(), shifts: self.shifts() }),
      type: "patch", contentType: "application/json",
      success: function(result) {
//        alert(result)
      }
    });
  };
}
