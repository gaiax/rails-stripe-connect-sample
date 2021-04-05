# frozen_string_literal: true

class AddExternalAccountToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.string :external_account_id, after: :stripe_account_id
    end
  end
end
