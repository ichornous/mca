FactoryGirl.define do
  factory :visit do |f|
    f.client_name { Faker::StarWars.character }
    f.car_name { Faker::StarWars.vehicle }
    f.description { Faker::Lorem.paragraph }

    f.phone_number { Faker::PhoneNumber.cell_phone }
    f.color { Visit.event_colors.sample }
    f.returning { false }

    s = Faker::Date.between(2.days.from_now, 5.days.from_now)
    f.start_date s
    f.end_date { s.advance(days: rand(4).to_i) }

    f.workshop
    f.order
  end
end
