FactoryGirl.define do
  # Default factory creates events which start yesterday and last until tomorrow (included).
  # There are a number of traits to alter such a behavior:
  # - started_4days_ago (start 4 days ago)
  # - started_4days_from_now (start 4 days in the future)
  # - last_4days (last 4 day)
  # - last_8days (last 8 days)
  factory :visit do
    client_name { Faker::StarWars.character }
    car_name { Faker::StarWars.vehicle }
    description { Faker::Lorem.paragraph }

    phone_number { Faker::PhoneNumber.cell_phone }
    color { Visit.event_colors.sample }
    returning { false }

    workshop
    order nil

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

    factory :visit_with_order do
      transient do
        service_count 3
      end

      after(:create) do |visit, evaluator|
        visit.order = create(:order, workshop: visit.workshop)
        create_list(:order_service, evaluator.service_count, order: visit.order)
        visit.save!
      end
    end

    factory :visit_invalid_fields do
      client_name { '' }
      color { 'rgb(123,45,67)' }
      start_date { 1.day.from_now }
      end_date { 1.day.ago }
    end
  end
end
