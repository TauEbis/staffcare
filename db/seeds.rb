# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env.development?
  if Heatmap.all.empty?
    Rake::Task["rs_load"].invoke
    renamed_l = Location.find_by(name: "PC Park Slope")
    renamed_l.name = "CityMD Park Slope"
    renamed_l.save
    puts "Created Heatmaps & added Locations as needed"   # Open and closing times currently need to be adjusted manually
  end

  if Zone.all.size < 2
    zones_to_locations = {
      "Manhattan" => ["CityMD 14th St", "CityMD 23rd St", "CityMD 37th St", "CityMD 57th St", "CityMD 67th St", "CityMD 86th St", "CityMD 88th St"],
      "Long Island" => ["CityMD Lake Grove", "CityMD Long Beach", "CityMD Massapequa", "PC Bellmore", "PC Commack", "PC East Meadow", "PC Great Neck", "PC Lindenhurst", "PC Lynbrook", "PC Mineola", "PC Syosset", "PC Carle Place", "PC Levittown", "CityMD Merrick"],
      "MetroNorth" => ["CityMD Yonkers", "Palisades"],
      "Brooklyn Queens" => ["CityMD Boerum Hill", "CityMD Bayridge", "PC Maspeth", "CityMD Astoria", "CityMD Park Slope", "CityMD Forest Hills"]
    }

    zones_to_locations.each do |z_name, l_names|
      z = Zone.find_or_create_by(name: z_name)
      l_names.each do |l_name|
        l = Location.find_or_create_by(name: l_name)
        l.zone = z
        l.save
      end
    end
    puts "Created Zones"
  end

  user = User.find_or_create_by!(email: 'admin@admin.com') do |user|
    user.password = user.password_confirmation = 'password'
    user.admin!
    Location.all.each do |location|
      user.locations << location unless user.locations.include?(location)
    end
    puts "Created Ops Admin User: #{user.email} / password"
  end

  user = User.find_or_create_by!(email: 'manager@manager.com') do |user|
    user.password = user.password_confirmation = 'password'
    user.manager!
    l= Location.find_by name: "CityMD 14th St"
    user.locations << l unless user.locations.include?(l)
    puts "Created Manager User for CityMD 14th St: #{user.email} / password"
  end

  user = User.find_or_create_by!(email: 'gm@gm.com') do |user|
    user.password = user.password_confirmation = 'password'
    user.gm!
    Zone.find_by(name: "Manhattan").locations.each do |location|
      user.locations << location unless user.locations.include?(location)
    end
    puts "Created GM User for Manhattan: #{user.email} / password"
  end

  if PatientVolumeForecast.all.empty?
    f = File.open("mock_data/patient_volume_forecasts.csv", "r")
    f.define_singleton_method(:original_filename) do
      "patient_volume_forecasts.csv"
    end
    PatientVolumeForecast.import(f)
    f.close
    puts "Created PatientVolumeForecasts"
  end

  fast_optimizer = true
  if fast_optimizer
    z=Zone.find_by(name: "Unassigned")
    locs = Zone.where.not(name: "Manhattan").map(&:locations).flatten
    z.locations << locs
    z.save
    puts "All non-manhattan sites set to \"Unassigned\" for faster optimizer runs"
    puts "Set \"fast_optimizer\" variable to false if you want all sites to be assigned"
  end

end
