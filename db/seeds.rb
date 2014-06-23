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

  user = User.find_or_create_by!(email: 'scheduler@scheduler.com') do |user|
    user.password = user.password_confirmation = 'password'
  end

  puts "Created Scheduler User: #{user.email} / password"

  ['Zone 1', 'Zone 2', 'Zone 3'].each do |zname|
    z = Zone.create!(name: zname)

    user.zones << z

    ['Location 1', 'Location 2', 'Location 3'].each do |lname|
      Location.create!(zone: z, name: "#{lname}-z#{z.id}")
    end
  end

  user.save!
end
