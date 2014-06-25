# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    name "MyString"
    zone
    rooms 5
    max_mds 3
    min_openers 1
    min_closers 1
    open_times [9,8,8,8,8,8,9]
    close_times [22,21,21,21,21,21,22]
  end
end
