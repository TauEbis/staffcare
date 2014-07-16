# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    sequence(:name) 				{ |n| "Location #{n}" }
    sequence(:report_server_id) { |n| "Location_#{n}" }
    zone
    rooms 5
    max_mds 3
    min_openers 1
    min_closers 1

    after(:build)  { |location| location.speeds << FactoryGirl.build(:speed, location: location) }
    before(:create)  { |location| location.speeds.each { |speed| speed.save } }
  end
end
