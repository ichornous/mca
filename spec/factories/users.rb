FactoryGirl.define do
  factory :user do
    workshop

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.user_name("#{first_name} #{last_name}") }
    email { Faker::Internet.email("#{first_name} #{last_name}") }
    confirmed_at { DateTime.now }
    password { Faker::Internet.password }
    #
    # Locale
    #
    trait :locale_en do
      locale {'en'}
    end

    trait :locale_ru do
      locale {'ru'}
    end

    #
    # Authority
    #
    trait :in_workshop do
      association :workshop, factory: :workshop_singleton
    end

    trait :in_disguise do
      workshop
      association :impersonation, factory: :workshop_singleton
    end

    #
    # Factory
    #
    factory :admin do
      role { :admin }
    end

    factory :manager do
      role { :manager }
    end

    factory :sales do
      role { :sales }
    end
  end
end