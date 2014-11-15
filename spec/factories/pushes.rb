# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :push do
    location_plan 		nil
    theory 						{ {} }
    log 							{ { log: "MyText" } }
  end
end
