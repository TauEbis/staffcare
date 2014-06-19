require 'date'

class TimePeriod

  attr_reader :days

     # start_date - Date object or string like '2013-02-10'
     # end_date - Date object or string like '2014-02-28'
     def initialize(start_date, end_date)
          if start_date.is_a? String
               @start_date = Date.parse(start_date)
          else
               @start_date = start_date
          end

          if end_date.is_a? String
               @end_date = Date.parse(end_date)
          else
               @end_date = end_date
          end

          @days = Array.new
          for i in 0..(@end_date - @start_date) do
               @days << @start_date + i
          end
     end
end
