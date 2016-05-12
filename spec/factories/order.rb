FactoryGirl.define do
  factory :order do
    workshop
    client nil
    car nil
    state nil
  end
end
