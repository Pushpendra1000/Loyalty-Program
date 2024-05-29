# frozen_string_literal: true

# RewardsController
class RewardsController < ApplicationController
  before_action :set_reward, only: %i[show update]

  def index
    render_success_response(
      { reward: array_serializer.new(@current_user.rewards.unexpired.unclaimed,
                                     serializer: RewardSerializer) }, I18n.t('reward.list')
    )
  end

  def show
    render_success_response({ reward: single_serializer.new(@reward, serializer: RewardSerializer) },
                            I18n.t('reward.show'))
  end

  def update
    return render_already_claimed if @reward.count.zero?

    update_reward
  end

  def render_already_claimed
    json_response({
                    success: true,
                    message: I18n.t('reward.already_claimed')
                  }, 200)
  end

  private

  def update_reward
    if @reward.update(
      claimed_at: Time.now, count: @reward.count - 1
    )
      render_success_response({ reward: single_serializer.new(@reward, serializer: RewardSerializer) },
                              I18n.t('reward.update'))
    end
  end

  def reward_params
    params.permit(:amount, :currency)
  end

  def set_reward
    @reward = @current_user.rewards.find(params[:id])
  end
end
