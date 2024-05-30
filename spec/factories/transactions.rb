# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    amount { 1000 }
    currency { 'us' }
    association :user
  end
end
