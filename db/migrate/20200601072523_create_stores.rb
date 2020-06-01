# frozen_string_literal: true

class CreateStores < ActiveRecord::Migration[6.0]
  def change
    create_table :stores do |t|
      t.integer :user_id
      t.string :name, unique: true, null: false, default: ''
      t.integer :service_fee, null: false, default: 0
      t.timestamps
      t.index :user_id
    end
  end
end
