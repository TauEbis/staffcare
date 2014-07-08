# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    name "MyString"
    zone
    rooms 5
    max_mds 3
    min_openers 1
    min_closers 1
  end
end
