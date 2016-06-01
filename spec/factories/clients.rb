FactoryGirl.define do
  factory :client do
    workshop

    name { Faker::StarWars.character }
    phone { Faker::PhoneNumber.cell_phone }
  end
end
