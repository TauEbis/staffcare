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
  end

  puts "Created Manager User: #{user.email} / password"

  user = User.find_or_create_by!(email: 'gm@gm.com') do |user|
    user.password = user.password_confirmation = 'password'
  end

  puts "Created GM User: #{user.email} / password"

  z = Zone.create(name: 'NYC1')
  user.zones << z
  user.save!

  z.locations.build(name: "CityMD_14th_St", report_server_id: "CityMD_14th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])
  z.locations.build(name: "CityMD_23rd_St", report_server_id: "CityMD_23rd_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])
  z.locations.build(name: "CityMD_57th_St", report_server_id: "CityMD_57th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])

  z = Zone.create(name: 'NYC2')

  z.locations.build(name: "CityMD_67th_St", report_server_id: "CityMD_67th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])
  z.locations.build(name: "CityMD_86th_St", report_server_id: "CityMD_86th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])
  z.locations.build(name: "CityMD_88th_St", report_server_id: "CityMD_88th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21])


  Zone.all.each do |zone|
    zone.locations.each do |location|
      location.speeds.create(doctors: 1, normal: 4, max: 6)
      location.speeds.create(doctors: 2, normal: 8, max: 12)
      location.speeds.create(doctors: 3, normal: 12, max: 18)
      location.speeds.create(doctors: 4, normal: 16, max: 24)
      location.speeds.create(doctors: 5, normal: 20, max: 30)
      location.save
    end
  end
end
