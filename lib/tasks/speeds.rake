namespace :speeds do

  task :reload_workrates => :environment do
    LocationPlan.where(normal: '{}', max: '{}').each do |lp|
	    attr =  {
	    	normal: [0] + lp.location.speeds.ordered.map(&:normal),
	    	max: 		[0] + lp.location.speeds.ordered.map(&:max)
	    	}
	    lp.update! attr
	  end
    puts "Reloaded max and normal workrates for legacy location plans"
  end

end