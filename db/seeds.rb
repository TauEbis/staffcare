# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# All ENVs

if Position.all.empty?
  Position.create_key_positions
  puts "Created Positions"
end

if Rule.all.empty?
  Rule.create_default_template
  puts "Created Rules"
end

if Rails.env.development?
  if Heatmap.all.empty? && Location.all.empty?
    Rake::Task["rs:dummy_visit_import"].invoke
    Rake::Task["hours:load"].invoke
    renamed_l = Location.find_by(name: "PC Park Slope")
    renamed_l.name = "CityMD Park Slope"
    renamed_l.save
    puts "Created Locations & Heatmaps"   # Open and closing times currently need to be adjusted manually
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

  if Zone.all.size == 1
    zones_for_locations = {
      "Manhattan" => ["CityMD 14th St", "CityMD 23rd St", "CityMD 37th St", "CityMD 57th St", "CityMD 67th St", "CityMD 86th St", "CityMD 88th St"],
      "Long Island" => ["CityMD Lake Grove", "CityMD Long Beach", "CityMD Massapequa", "PC Bellmore", "PC Commack", "PC East Meadow", "PC Great Neck", "PC Lindenhurst", "PC Lynbrook", "PC Mineola", "PC Syosset", "PC Carle Place", "PC Levittown", "CityMD Merrick"],
      "MetroNorth" => ["CityMD Yonkers", "Palisades"],
      "Brooklyn Queens" => ["CityMD Boerum Hill", "CityMD Bayridge", "PC Maspeth", "CityMD Astoria", "CityMD Park Slope", "CityMD Forest Hills"]
    }

    zones_for_locations.each do |z_name, l_names|
      z = Zone.find_or_create_by(name: z_name)
      locs = Location.where(name: l_names)
      z.locations << locs
      z.save
    end
    puts "Created Zones"

    fast_optimizer = true
    if fast_optimizer
      z = Zone.find_by(name: "Unassigned")
      man = Zone.find_by(name: "Manhattan")
      locs = Location.where.not(zone: man)
      z.locations << locs
      z.save
      puts "All non-manhattan sites set to \"Unassigned\" Zone for faster optimizer runs"
      puts "Set \"fast_optimizer\" variable to false if you want all sites to be assigned to actual Zones"
    end
  end

  if User.all.empty?
    user = User.find_or_create_by!(email: 'admin@admin.com') do |user|
      user.password = user.password_confirmation = 'password'
      user.name = 'Admin User'
      user.admin!
      Location.all.each do |location|
        user.locations << location unless user.locations.include?(location)
      end
      puts "Created Ops Admin User: #{user.email} / password"
    end

    user = User.find_or_create_by!(email: 'manager@manager.com') do |user|
      user.password = user.password_confirmation = 'password'
      user.name = 'Manager User'
      user.manager!
      locs = Location.find_by name: "CityMD 14th St"
      user.locations << locs
      puts "Created Manager User for CityMD 14th St: #{user.email} / password"
    end

    user = User.find_or_create_by!(email: 'rm@rm.com') do |user|
      user.password = user.password_confirmation = 'password'
      user.name = 'RM User'
      user.rm!
      locs = Zone.find_by(name: "Manhattan").locations
      user.locations << locs
      puts "Created RM User for Manhattan: #{user.email} / password"
    end
  end

end

