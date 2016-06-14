FactoryGirl.define do
  factory :order do
    workshop
    client
    car
    state 'NEW'

    description { Faker::Lorem.paragraph }
    color { Order.event_colors.sample }

    start_date 0.days.from_now
    end_date 1.day.from_now

    factory :order_in_range do
      transient do
        s0 0.days.from_now
        e0 1.day.from_now
      end

      start_date { s0 + rand((e0.to_date - s0.to_date).to_i).days }
      end_date { s0 + rand((e0.to_date - s0.to_date).to_i).days }
    end
  end
end
