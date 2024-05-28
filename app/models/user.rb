# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  has_secure_password
  has_many :transactions, dependent: :destroy
  has_many :loyalty_points, dependent: :destroy
  has_many :rewards, dependent: :destroy
  enum tier: { standard: 'standard', gold: 'gold', platinum: 'platinum' }
  scope :birthday_month, -> { where('EXTRACT(MONTH FROM birthday) = ?', Date.today.month) }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, :birthday, presence: true

  validates :password, length: { within: 6..16 },
                       format: { with: /\A[A-Za-z0-9]+\z/,
                                 message: 'only allows letters and numbers' }, if: -> { password.present? }

  def available_points
    loyalty_points.unexpired.sum(&:received_points)
  end
end
