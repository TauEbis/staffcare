namespace :hours do

  # To write this json to a file such as mock_data/hours.json
  # you may neeed to .gsub('\"', '"')
  desc "Opening hours per location keyed by uid as JSON"
  task :dump => :environment do
    h = {}
    Location.ordered.each do |l|
      h[l.uid] = l.attributes.slice(*Location::DAY_PARAMS.map(&:to_s))
    end
    puts h.to_json
  end

  desc "Loading opening hours from hours.json"
  task :load => :environment do
    opening_hours = JSON.parse( File.read('mock_data/hours.json'))
    opening_hours.each do |k,v|
      if l = Location.find_by(uid: k)
        v.each do | day_param, time |
          l.send("#{day_param}=".to_sym, time.to_i)
        end
        l.save!
      end
    end
  end

end