namespace :rs do

  desc "This task is called by the Heroku scheduler add-on to import the RS data"
  task :scheduled_visit_import => :environment do
    if Date.today.wday == 1
      ReportServerFactory.new.scheduled_import!
      ShortForecast.build_latest!
    end
  end

end