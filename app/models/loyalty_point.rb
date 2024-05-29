# frozen_string_literal: true

# LoyaltyPoint Model
class LoyaltyPoint < ApplicationRecord
  belongs_to :user
  belongs_to :user_transaction, class_name: 'Transaction', foreign_key: :transaction_id, optional: true
  # rubocop:disable Layout/LineLength
  scope :monthly_points, lambda {
                           where('created_at >= ? AND created_at <= ?', Time.now.beginning_of_month, Time.now.end_of_month)
                         }
  # rubocop:enable Layout/LineLength
  scope :unexpired, -> { where(expired: false) }
end
