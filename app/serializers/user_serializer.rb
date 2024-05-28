# frozen_string_literal: true

# UserSerializer
class UserSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :email,
    :birthday,
    :tier,
    :available_points,
    :created_at,
    :updated_at
  )
end
