# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env.development?
  user = User.find_or_create_by!(email: 'admin@admin.com') do |user|
    user.password = user.password_confirmation = 'password'
    user.admin!
  end

  puts "Created Admin User: #{user.email} / password"

  user = User.find_or_create_by!(email: 'manager@manager.com') do |user|
    user.password = user.password_confirmation = 'password'
    user.role = :manager
  end

  puts "Created Manager User: #{user.email} / password"

  user = User.find_or_create_by!(email: 'gm@gm.com') do |user|
    user.password = user.password_confirmation = 'password'
    user.role = :gm
  end

  puts "Created GM User: #{user.email} / password"

  z1 = Zone.find_or_create_by(name: 'NYC1')

  if z1.locations.empty?
    z1.locations.build(name: "CityMD_14th_St", report_server_id: "CityMD_14th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])
    z1.locations.build(name: "CityMD_23rd_St", report_server_id: "CityMD_23rd_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])
    z1.locations.build(name: "CityMD_57th_St", report_server_id: "CityMD_57th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])

    z1.locations.each do |location|
      location.speeds.build(doctors: 1, normal: 4, max: 6)
      location.speeds.build(doctors: 2, normal: 8, max: 12)
      location.speeds.build(doctors: 3, normal: 12, max: 18)
      location.speeds.build(doctors: 4, normal: 16, max: 24)
      location.speeds.build(doctors: 5, normal: 20, max: 30)
      location.save!
    end
  end

  z2 = Zone.find_or_create_by(name: 'NYC2')

  if z2.locations.empty?
    z2.locations.build(name: "CityMD_67th_St", report_server_id: "CityMD_67th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])
    z2.locations.build(name: "CityMD_86th_St", report_server_id: "CityMD_86th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])
    z2.locations.build(name: "CityMD_88th_St", report_server_id: "CityMD_88th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])

    z2.locations.each do |location|
      location.speeds.build(doctors: 1, normal: 4, max: 6)
      location.speeds.build(doctors: 2, normal: 8, max: 12)
      location.speeds.build(doctors: 3, normal: 12, max: 18)
      location.speeds.build(doctors: 4, normal: 16, max: 24)
      location.speeds.build(doctors: 5, normal: 20, max: 30)
      location.save!
    end
  end

  gm = User.find_by email: 'gm@gm.com'
  z1.locations.each do |location|
    gm.locations << location unless gm.locations.include?(location)
  end

  manager = User.find_by email: 'manager@manager.com'
  l= Location.find_by name: "CityMD_14th_St"
  manager.locations << l unless manager.locations.include?(l)

  if PatientVolumeForecast.all.empty?
    f = File.open("mock_data/volume_data_1.csv", "r")
    f.define_singleton_method(:original_filename) do
      "volume_data_1.csv"
    end
    PatientVolumeForecast.import(f)
    f.close
  end
end
