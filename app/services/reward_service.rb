# frozen_string_literal: true

# Reward Service
class RewardService
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def birthday_month_reward
    one_time_reward(
      I18n.t('reward.birthday_month_reward.title'),
      I18n.t('reward.birthday_month_reward.description')
    )
  end

  def monthly_spent_reward
    return unless user.loyalty_points.monthly_points.sum(:received_points) > 100

    unlimited_time_reward(
      I18n.t('reward.monthly_spend_reward.title'),
      I18n.t('reward.monthly_spend_reward.description')
    )
  end

  def quarterly_spent_reward
    return unless user.transactions.quarterly_spend.sum(:amount) > 2000

    user.loyalty_points.create(received_points: 100, valid_till: 1.year.from_now)
  end

  def rebate_on_transactions
    transactions = user.transactions.where('amount > ?', 100)

    return unless transactions.count >= 10

    rebate_amount = transactions.sum { |t| t.amount * 0.05 }
    one_time_reward(
      I18n.t('reward.rebate_on_transactions.title'),
      I18n.t('reward.rebate_on_transactions.description', rebate_amount:)
    )
  end

  def movie_ticket_reward
    return unless user.transactions.exists?

    start_date = user.transactions.first.created_at
    end_date = start_date + 60.days
    total_spent = user.transactions.where(created_at: start_date..end_date).sum(&:amount)

    return unless total_spent > 1000

    one_time_reward(
      I18n.t('reward.movie_ticket_reward.title'),
      I18n.t('reward.movie_ticket_reward.description')
    )
  end

  def upgrade_user
    earned_points = user.loyalty_points.where(created_at: (Time.now - 2.years)..Time.now).sum(:received_points)
    if earned_points >= 5000
      user.platinum!
    elsif (1000..4999).include?(earned_points)
      user.gold!
      one_time_reward(
        I18n.t('reward.airport_lounge_reward.title'), I18n.t('reward.airport_lounge_reward.description'), 4
      )
    end
  end

  private

  def one_time_reward(name, description, count = 1)
    user.rewards.create_with(valid_till: 1.year.from_now, count:).find_or_create_by(name:, description:)
  end

  def unlimited_time_reward(name, description)
    user.rewards.create(name:, description:, valid_till: 1.year.from_now)
  end
end
