# frozen_string_literal: true

# CreateLoyaltyPoints Migration
class CreateLoyaltyPoints < ActiveRecord::Migration[7.0]
  def change
    create_table :loyalty_points do |t|
      t.references :user, null: false, foreign_key: true
      t.references :transaction, null: false, foreign_key: true
      t.integer :received_points
      t.date :valid_till

      t.timestamps
    end
  end
end
