FactoryGirl.define do
  factory :order_service do
    service
    order nil
    amount { Faker::Number.decimal(2) }
    cost { Faker::Number.decimal(2) }
    time { Faker::Number.decimal(2) }
  end
end
