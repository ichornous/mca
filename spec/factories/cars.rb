FactoryGirl.define do
  factory :car do
    workshop
    license_id { Faker::Number.number(8) }
    description { Faker::StarWars.vehicle }
  end
end
