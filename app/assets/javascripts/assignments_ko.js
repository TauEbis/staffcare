var assignmentContext;

// Not called a Shift right now because of a name collision
function Assignment(data) {
  var self = this;
  self.id = ko.observable(data.id);
  self.starts_hour = ko.observable(data.starts_hour);
  self.ends_hour = ko.observable(data.ends_hour);
  //self.physician_initials = ko.observable(data.physician_initials);

  /////  DEMO CODE FOR EFFECT
  self.physician_initials = ko.pureComputed(function() {
    if(self.id() % 3 == 0 || self.id() % 7 == 0) {
      return '--'
    } else {
      return 'DB'
    }
  });

  self.selected_physician = ko.pureComputed(function() {
    if(self.id() % 3 == 0 || self.id() % 7 == 0) {
      return 'Unassigned'
    } else {
      return 'Drew Blas'
    }
  });

  self.css_class = ko.pureComputed(function() {
    if(self.id() % 3 == 0 || self.id() % 7 == 0) {
      return 'danger'
    } else {
      return ''
    }
  })
  /////  END DEMO CODE FOR EFFECT

  self.timeLabel = ko.pureComputed(function() {
    return timeOfDay(self.starts_hour()) + " - " + timeOfDay(self.ends_hour());
  });
}

function DayData(data, parent) {
  var self = this;
  self.date = ko.observable(data.date);
  self.location_plan = parent;
  self.shifts = ko.observableArray($.map(data.shifts, function(elem, i){
    return new Assignment(elem);
  }));

  self.displayDay = function() {
    assignmentContext.selected_day(self);
    $('#showAssignmentModal').modal();
  };

  self.url = "/location_plans/" + parent.id();
}

function LocationPlan(data) {
  var self = this;
  self.id = ko.observable(data.id);
  self.name = ko.observable(data.name);
  self.days = ko.observableArray($.map(data.days, function(elem, i){
    return new DayData(elem, self);
  }));
}

function AssignmentViewModel() {
  var self = this;

  self.schedule_id = ko.observable(0);
  self.location_plan_ids = ko.observableArray([]);
  self.location_plans = ko.observableArray([]);

  self.selected_day = ko.observable(null);

  self.url = ko.pureComputed(function() {
    return "/assignments?schedule_id=" + self.schedule_id();
  });

  self.physician_list = ['Unassigned', 'Drew Blas', 'Rio Bennin'];

  self.load_all = function() {
    self.fetch_data(self.url(), self.load);
  };

  self.fetch_data = function(url, callback) {
    $.ajax(url, {dataType: "json", data: {page: 1}} )
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
      return new LocationPlan(location_plan);
    });

    self.location_plans(c);
  };


}

$(document).ready(function() {
  var assignment_view = $('#assignment_view');
  var d = assignment_view.data();
  if(d) {
    assignmentContext = new AssignmentViewModel();
    ko.applyBindings(assignmentContext);

    assignmentContext.schedule_id(d.scheduleId);
    assignmentContext.load_all();
  }
});
