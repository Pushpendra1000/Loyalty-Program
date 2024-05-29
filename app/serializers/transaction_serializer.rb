# frozen_string_literal: true

# TransactionSerializer
class TransactionSerializer < ActiveModel::Serializer
  attributes(
    :user_id,
    :id,
    :amount,
    :currency,
    :created_at,
    :updated_at
  )
end
