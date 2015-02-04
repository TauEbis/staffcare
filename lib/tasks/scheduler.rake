namespace :rs do

  desc "This task is called by the Heroku scheduler add-on to import the RS data"
  task :scheduled_visit_import => :environment do
    Rake::Task["weekly_visit_import"].invoke if Date.today.wday == 1
  end

end