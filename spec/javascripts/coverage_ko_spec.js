//= require spec_helper
//= require coverage_ko

  describe('Position', function() {
    var visits   = {8:0, 9:4.1, 10:6.4, 11:6.8, 12:5.2, 13:4.9, 14:2.7, 15:3, 16:1, 17:2}
      , data     = { visits: visits }
    ;

    it('provides visits for averaging patients per hour', function() {
      var position = new Position(data);
      expect( position ).to.equal(1);
    });
  });

  describe('Shift', function() {
    var visits = {8:0, 9:4.1, 10:6.4, 11:6.8, 12:5.2, 13:4.9, 14:2.7, 15:3, 16:1, 17:2}
      , starts_hour = 8
      , ends_hour   = 9
      , shift = new Shift({ starts_hour: starts_hour, ends_hour: ends_hour })
    ;

    describe('.distribute_hourly', function() {
      it('provides visits for averaging patients per hour', function() {
        shift.distribute_hourly(visits);

        expect( shift.visit_distribution() ).to.equal(1);
      });
     });

    describe('.patients_per_hour', function() {
        // are these visits or patients?
        // If visits then why no visits_per_hour?
        , patients_per_hour = (visit_distribution
                                 .reduce(function(a,b) { return a+b; })
                                 / visit_distribution.length)
      ;

      it('averages the patients per hour based on hourly visit distribution', function() {
        expect( shift.patients_per_hour() ).to.equal( patients_per_hour );
      });
    });

  describe('.hours', function() {
    var visit_distribution = [0, 4.1, 6.4, 6.8, 5.2, 4.9, 2.7, 3, 1]
      , starts_hour = 0
      , ends_hour   = 10
      , data = {starts_hour: starts_hour, ends_hour: ends_hour, visit_distribution: visit_distribution}
      , shift = new Shift(data)
    ;

    it('subtracts starting hour from ending hour', function() {
      expect( shift.hours() ).to.equal(ends_hour - starts_hour);
    });
  });
  });
