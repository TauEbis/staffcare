namespace :cron do
  desc "Send missed TODO notifications to users"
  task :missed_notices => :environment do
    TodoNotifier.missed!
  end
end
