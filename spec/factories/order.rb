FactoryGirl.define do
  factory :order do
    workshop
    booking nil
    client
    car
    state nil

    factory :order_with_booking do
      transient do
        start_date 0.days.from_now
        end_date 1.day.from_now
      end

      booking nil
      after(:create) do |order, evaluator|
        order.booking = create(:booking, start_date: evaluator.start_date, end_date: evaluator.end_date, order: order)
        order.save!
      end
    end

    factory :order_in_range do
      transient do
        start_date nil
        end_date nil

        s0 { start_date + rand((end_date.to_date - start_date.to_date).to_i).days }
        e0 { s0 + rand((end_date.to_date - s0.to_date).to_i).days }
      end

      booking nil
      after(:create) do |order, evaluator|
        order.booking = create(:booking, start_date: evaluator.s0, end_date: evaluator.e0, order: order)
        order.save!
      end
    end
  end
end
