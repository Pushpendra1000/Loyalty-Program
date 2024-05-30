# frozen_string_literal: true

FactoryBot.define do
  factory :loyalty_point do
    received_points { 10 }
    valid_till { Date.today + 1.month }
    expired { false }
    association :user
    association :user_transaction, factory: :transaction
  end
end
