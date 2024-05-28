# frozen_string_literal: true

# CreateTransactions Migration
class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.integer :amount
      t.string :currency

      t.timestamps
    end
  end
end
