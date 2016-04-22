factory :visit do |f|
  f.firstname { Faker::Name.first_name }
  f.lastname { Faker::Name.last_name }
end
