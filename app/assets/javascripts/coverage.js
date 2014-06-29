// Class to represent a row in the list of all shifts for a day
function Shift(starts, ends) {
  var self = this;
  self.starts = ko.observable(starts);
  self.ends = ko.observable(ends);
  self.hours = ko.computed(function(){
    return self.ends() - self.starts();
  });
}

// Overall viewmodel for a day, along with initial state
function CoverageViewModel() {
  var self = this;

  self.availableTimes = [
    {num: 8, formatted: '8:00am'},
    {num: 8.5, formatted: '8:30am'},
    {num: 10, formatted: '10:00am'},
    {num: 12, formatted: '12:00pm'},
    {num: 20, formatted: '8:00pm'}
  ]

  // Editable data
  self.shifts = ko.observableArray([
    new Shift(8, 12),
    new Shift(12, 20)
  ]);

  self.addShift = function() {
    self.shifts.push(new Shift(10,20));
  };

  self.removeShift = function(shift) { self.shifts.remove(shift) };

  self.totalHours = ko.computed(function() {
    var total = 0;
    for (var i = 0; i < self.shifts().length; i++)
      total += self.shifts()[i].hours();
    return total;
  });
}


