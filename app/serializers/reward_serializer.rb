# frozen_string_literal: true

# RewardSerializer
class RewardSerializer < ActiveModel::Serializer
  attributes(
    :user_id,
    :id,
    :name,
    :description,
    :claimed_at,
    :created_at,
    :updated_at
  )
end
