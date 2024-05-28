# frozen_string_literal: true

# AddColumnToLoyaltyPoint Migration
class AddColumnToLoyaltyPoint < ActiveRecord::Migration[7.0]
  def change
    add_column :loyalty_points, :expired, :boolean, default: false
  end
end
