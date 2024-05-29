class RewardsJob < ApplicationJob
  queue_as :default

  def perform(action)
    return if action == 'monthly_spent_reward' && Date.today != Date.today.end_of_month

    return if action == 'quarterly_spent_reward' && Date.today != Date.today.end_of_quarter

  if action == "points_expiration"
      send(action)
    else
      load_users.find_each do |user|
        service(user).send(action)
      end
    end
  end

  private

  def points_expiration
    load_users.find_each do |user|
      user.loyalty_points.unexpired.where('valid_till < ?', Date.today).update_all(expired: true)
    end
  end

  def load_users
    User.includes(:transactions, :loyalty_points)
  end

  def service(user)
    RewardService.new(user)
  end
end
