FactoryGirl.define do
  # Default factory creates events which start yesterday and last until tomorrow (included).
  # There are a number of traits to alter such a behavior:
  # - started_4days_ago (start 4 days ago)
  # - started_4days_from_now (start 4 days in the future)
  # - last_4days (last 4 day)
  # - last_8days (last 8 days)
  factory :booking do
    description { Faker::Lorem.paragraph }
    color { Booking.event_colors.sample }

    start_date 1.day.ago
    end_date { start_date.advance(days: 2) }

    trait :started_4days_ago do
      start_date 4.days.ago
    end

    trait :started_4days_from_now do
      start_date 4.days.from_now
    end

    trait :last_4days do
      end_date { start_date.advance(days: 4) }
    end

    trait :last_8days do
      end_date { start_date.advance(days: 8) }
    end

    factory :booking_with_order do
      transient do
        service_count 3
        order_workshop { create(:workshop) }
      end

      after(:create) do |booking, evaluator|
        booking.order = create(:orders, workshop: evaluator.order_workshop)
        create_list(:order_service, evaluator.service_count, orders: booking.order)
        booking.save!
      end
    end

    factory :booking_invalid_fields do
      color { 'rgb(123,45,67)' }
      start_date { 1.day.from_now }
      end_date { 1.day.ago }
    end
  end
end
