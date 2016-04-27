FactoryGirl.define do
  factory :workshop do |f|
    f.description { Faker::Lorem.paragraph }
    f.color nil
  end
end
