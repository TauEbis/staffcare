var staffingContext;

function StaffingViewModel() {
  var self = this;

  self.schedule_id = ko.observable(0);
  self.location_ids = ko.observableArray([]);
  self.start_date  = ko.observable("");
  self.end_date  = ko.observable("");

  self.url = ko.pureComputed(function() {
    return "/schedules/" + self.schedule_id() + "/staffings/table";
  });

  self.fetch_data = function() {
    var data = {
      location_ids: self.location_ids(),
      start_date:   self.start_date(),
      end_date:     self.end_date()
    };

    $.ajax(self.url(), {data: data} )
      .done(function(data, status, xhr) {
        console.log(data);
        self.load(data);
      })
      .fail(function(xhr, status, error) {
        alert("Error loading comments");
        console.log("Error loading comments");
        console.log(xhr);
        console.log(status);
        console.log(error);
      });
  };

  self.load = function(data) {
    console.log("Load finished");
  };
}

$(document).ready(function() {
  var staffing_view = $('#staffings_display');
  var d = staffing_view.data();
  if(d) {

    staffingContext = new StaffingViewModel();
    ko.applyBindings(staffingContext);

    staffingContext.schedule_id(d.scheduleId);
    staffingContext.fetch_data()
  }
});
