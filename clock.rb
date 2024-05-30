# frozen_string_literal: true

require 'clockwork'
require 'active_support/time' # Allow numeric durations (eg: 1.minutes)
require_relative './config/boot'
require_relative './config/environment'
require_relative './config/application'

# ClockWork
module Clockwork
  every(1.month, 'birthday_month_reward', at: '00:05', if: ->(t) { t.day == 1 }) do
    RewardsJob.perform_later('birthday_month_reward')
  end

  every(1.month, 'monthly_spent_reward', at: '23:57', if: ->(t) { t.mday == Time.now.end_of_month.day }) do
    RewardsJob.perform_later('monthly_spent_reward')
  end

  # rubocop:disable Layout/LineLength
  every(1.month, 'quarterly_spent_reward', at: '23:57', if: lambda { |t|
                                                              t.end_of_quarter.month == t.month && t.mday == t.end_of_quarter.mday
                                                            }) do
    # rubocop:enable Layout/LineLength
    RewardsJob.perform_later('quarterly_spent_reward')
  end

  every(1.day, 'movie_ticket_reward', at: '00:01') do
    RewardsJob.perform_later('movie_ticket_reward')
  end

  every(1.day, 'rebate_on_transactions', at: '00:01') do
    RewardsJob.perform_later('rebate_on_transactions')
  end

  every(1.hour, 'points_expiration') do
    RewardsJob.perform_later('points_expiration')
  end

  every(1.hour, 'upgrade_user') do
    RewardsJob.perform_later('upgrade_user')
  end
end
