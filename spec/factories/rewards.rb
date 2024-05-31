# frozen_string_literal: true

FactoryBot.define do
  factory :reward do
    # Add attributes here
    name { 'Coffee Reward' }
    claimed_at { nil }
    association :user
  end
end
