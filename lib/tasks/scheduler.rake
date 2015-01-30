namespace :rs do

  desc "This task is called by the Heroku scheduler add-on to import the RS data"
  task :scheduled_visit_import => :environment do
    ReportServerFactory.new.weekly_import! if Date.today.wday == 1
  end

end