var assignmentContext;

// Not called a Shift right now because of a name collision
function Assignment(data) {
  var self = this;
  self.id = ko.observable(data.id);
  self.starts_hour = ko.observable(data.starts_hour);
  self.ends_hour = ko.observable(data.ends_hour);

  self.mini_starts_hour = ko.pureComputed(function() {
    return miniTimeOfDay(self.starts_hour())
  });

  self.mini_ends_hour = ko.pureComputed(function() {
    return miniTimeOfDay(self.ends_hour())
  });

  self.timeLabel = ko.pureComputed(function() {
    return timeOfDay(self.starts_hour()) + " - " + timeOfDay(self.ends_hour());
  });

  self.hours = ko.computed(function(){
    return self.ends_hour() - self.starts_hour();
  });

  self.shift_bar_width = ko.computed(function(){
    //TODO: usage of shift_bar_width should be removed as it is not a concern of the shift
    var hourly_bar_width = 46;

    return (self.hours() * hourly_bar_width) + "px";
  });

  self.shift_bar_offset = ko.computed(function(){
    //TODO: usage of shift_bar_offset should be removed as it is not a concern of the shift
    var opens = 8 // this is very brittle. Should be coming from the Grade open time.
      , hourly_bar_width = 46
    ;

    return ((self.starts_hour() - opens) * hourly_bar_width) + "px";
  });
}

function DayData(data, parent, index) {
  var self = this;
  self.index = index;

  // None of this changes, so instead of wrapping in an observable and a bunch of computed properties, we just eval it once
  self.date = moment(data.date);
  self.raw_date = data.date;
  self.dow = self.date.format("ddd").charAt(0);
  self.day_num = self.date.format("D");
  self.is_weekend = self.date.day() == 6 || self.date.day() == 0;
  self.is_holiday = parent.holidays.indexOf(data.date) != -1;
  self.is_weekend_or_holiday = self.is_weekend || self.is_holiday;
  console.log(self.is_holiday);
  self.is_sunday = self.date.day() == 0;
  self.location_plan = parent;

  self.shifts = ko.observableArray($.map(data.shifts, function(elem, i){
    return new Assignment(elem);
  }));

  self.displayDay = function() {
    assignmentContext.selected_day(self);
    $('#show_assignment_modal').modal();
    load_highcharts(self.location_plan.chosen_grade_id, self.raw_date );
  };

  self.total_hours = function() {
    var total = 0;
    self.shifts().forEach(function(shift, i) {
      total += shift.ends_hour() - shift.starts_hour();
    });
    return total;
  };

  self.hours_for_week = function() {
    return self.location_plan.hours_for_week(self.index);
  };

  self.url = "/location_plans/" + parent.id();
}

function LocationPlan(data, holidays) {
  var self = this;
  self.id = ko.observable(data.id);
  self.name = ko.observable(data.name);
  self.chosen_grade_id = data.chosen_grade_id;
  self.holidays = holidays;
  self.days = ko.observableArray($.map(data.days, function(elem, i){
    return new DayData(elem, self, i);
  }));

  // Calculates the total hours of the 7 days of the week ending on the given day
  self.hours_for_week = function(index) {
    var min = index - 6;
    if (min < 0) { min = 0 }

    var total = 0;

    for(var i=min; i <= index; i++){
      total += self.days()[i].total_hours();
    }

    return total;
  }
}

function AssignmentViewModel() {
  var self = this;

  self.schedule_id = ko.observable(0);
  self.zone_id = ko.observable(0);
  self.start_date = ko.observable(0);
  self.end_date = ko.observable(0);
  self.holidays = ko.observableArray([]);
  self.location_plans = ko.observableArray([]);

  self.selected_day = ko.observable(null);

  self.url = "/assignments";

  self.load_all = function() {
    self.fetch_data(self.url, self.load);
  };

  self.fetch_data = function(url, callback) {
    $.ajax(url, {dataType: "json", data: {
        schedule_id: self.schedule_id(),
        zone_id: self.zone_id(),
        start_date: self.start_date(),
        end_date: self.end_date()
      }} )
      .done(function(data, status, xhr) {
        callback(data);
      })
      .fail(function(xhr, status, error) {
        alert("Error loading assignments");
        console.log("Error loading assignments");
        console.log(xhr);
        console.log(status);
        console.log(error);
      });
  };

  self.load = function(data) {
    var c = jQuery.map(data.location_plans, function(location_plan, i){ // Actually a flatmap. Stupid jQuery
      return new LocationPlan(location_plan, data.holidays);
    });

    self.location_plans(c);
  };
}

$(document).ready(function() {
  var assignment_view = $('#assignment_view');
  var d = assignment_view.data();
  if(d) {
    $('.table-fixed-header').fixedHeader({column_freeze: true});
    assignmentContext = new AssignmentViewModel();
    ko.applyBindings(assignmentContext);

    assignmentContext.schedule_id(d.scheduleId);
    assignmentContext.zone_id(d.zoneId);
    assignmentContext.start_date(d.startDate);
    assignmentContext.end_date(d.endDate);
    assignmentContext.holidays(d.holidays);
    assignmentContext.load_all();
  }

  var zoom_level = 100;

  $('#assignment_zoom_in').on('click', function() {
    zoom_level = zoom_level + 20;
    assignment_view.css('zoom', zoom_level + "%");
  });
  $('#assignment_zoom_out').on('click', function() {
    zoom_level = zoom_level - 20;
    assignment_view.css('zoom', zoom_level + "%");
  });
});