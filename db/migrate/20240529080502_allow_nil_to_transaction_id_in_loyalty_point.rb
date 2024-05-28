# frozen_string_literal: true

# AllowNilToTransactionIdInLoyaltyPoint Migration
class AllowNilToTransactionIdInLoyaltyPoint < ActiveRecord::Migration[7.0]
  def change
    change_column :loyalty_points, :transaction_id, :integer, null: true
  end
end
