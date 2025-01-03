# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false, limit: 256
      t.integer :registration_number, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
