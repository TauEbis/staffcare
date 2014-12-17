desc "This task is called by the Heroku scheduler add-on to import the RS data"
task :rs_monthly_import => :environment do
  ReportServerFactory.new.import! if Date.today.day == 17
end