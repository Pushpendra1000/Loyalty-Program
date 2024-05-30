# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    birthday { '1990-01-01' }
    password { 'password123' }
    password_confirmation { 'password123' }
    tier { :standard }

    trait :gold do
      tier { :gold }
    end

    trait :platinum do
      tier { :platinum }
    end
  end
end
