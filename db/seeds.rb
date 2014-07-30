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

  z0 = Zone.find_or_create_by(name: 'Unassigned')
  z1 = Zone.find_or_create_by(name: 'NYC1')

  if z1.locations.empty?
    z1.locations.build(name: "CityMD_14th_St", report_server_id: "CityMD_14th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21], uid: "3ecc8854-f77b-4834-b42f-6b0e4d498b43")
    z1.locations.build(name: "CityMD_23rd_St", report_server_id: "CityMD_23rd_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21], uid: "d64f5748-ce3e-4961-89a3-c70ac9c2338a")
    z1.locations.build(name: "CityMD_57th_St", report_server_id: "CityMD_57th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21], uid: "414f0bd3-0460-405d-9136-0f16db212ba9")

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
    z2.locations.build(name: "CityMD_67th_St", report_server_id: "CityMD_67th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21], uid: "37871c17-1e7d-4a18-a2c4-d6cf09421b0f")
    z2.locations.build(name: "CityMD_86th_St", report_server_id: "CityMD_86th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21], uid: "44734173-f277-4643-8d3b-dfaeee3c04b5")
    z2.locations.build(name: "CityMD_88th_St", report_server_id: "CityMD_88th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21], uid: "cd8d8bad-cec1-4f07-a826-bf52ca990222")

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
