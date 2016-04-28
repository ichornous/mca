FactoryGirl.define do
  factory :workshop do
    description Faker::StarWars.planet
    color Faker::Color.hex_color

    factory :workshop_singleton do
      id 1
      initialize_with {
        Workshop.where(id: id).first_or_create
      }
    end
  end
end
