FactoryGirl.define do
  factory :order do
    workshop
    client nil
    car nil
    state nil

    factory :order_lock_workshop do
      association :workshop, factory: :workshop_singleton
    end
  end
end
