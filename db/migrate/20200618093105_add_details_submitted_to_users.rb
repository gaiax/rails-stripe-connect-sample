# frozen_string_literal: true

class AddDetailsSubmittedToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.boolean :details_submitted, null: false, default: false, after: :stripe_account_id
    end
  end
end
