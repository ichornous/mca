FactoryGirl.define do
  factory :service do
    name { Faker::Hacker.abbreviation }
    description { Faker::Superhero.power }
    base_cost { Faker::Number.decimal(2) }
    base_time { Faker::Number.decimal(2) }
  end
end
