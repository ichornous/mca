FactoryGirl.define do
  factory :visit do
    client_name { Faker::StarWars.character }
    car_name { Faker::StarWars.vehicle }
    description { Faker::Lorem.paragraph }

    phone_number { Faker::PhoneNumber.cell_phone }
    color { Visit.event_colors.sample }
    returning { false }

    workshop
    order nil

    start_date DateTime.now
    end_date { start_date }


    trait :in_the_past do
      start_date 1.month.ago
    end

    trait :in_the_future do
      start_date 1.month.from_now
    end

    trait :short do
      end_date { start_date.advance(days: 1) }
    end

    trait :long do
      end_date { start_date.advance(days: 4) }
    end
  end
end
