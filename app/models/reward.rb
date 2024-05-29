# frozen_string_literal: true

# Reward Model
class Reward < ApplicationRecord
  belongs_to :user
  validates :name, presence: true
  scope :unclaimed, -> { where(claimed_at: nil) }
  scope :unexpired, -> { where('valid_till > ?', Date.today) }
end
