# frozen_string_literal: true

# Transaction Model
class Transaction < ApplicationRecord
  belongs_to :user
  has_one :loyalty_point, dependent: :destroy
  after_create :assign_points

  validates :amount, :currency, presence: true

  # rubocop:disable Layout/LineLength
  scope :quarterly_spend, lambda {
                            where('created_at >= ? AND created_at <= ?', Time.now.beginning_of_quarter, Time.now.end_of_quarter)
                          }

  # rubocop:enable Layout/LineLength
  def assign_points
    return if received_points.zero?

    create_loyalty_point(received_points: received_points * 10, valid_till: Date.today + 1.year, user_id: user.id)
  end

  def received_points
    if currency == 'us'
      amount.to_i / 100
    else
      (amount.to_i / 100) * 2
    end
  end
end
