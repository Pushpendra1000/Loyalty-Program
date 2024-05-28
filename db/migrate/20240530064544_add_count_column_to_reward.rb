# frozen_string_literal: true

# AddCountColumnToReward Migration
class AddCountColumnToReward < ActiveRecord::Migration[7.0]
  def change
    add_column :rewards, :count, :integer, default: 1
    add_column :rewards, :valid_till, :date
  end
end
