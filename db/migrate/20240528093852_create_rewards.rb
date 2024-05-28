# frozen_string_literal: true

# CreateRewards Migration
class CreateRewards < ActiveRecord::Migration[7.0]
  def change
    create_table :rewards do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.date :claimed_at

      t.timestamps
    end
  end
end
