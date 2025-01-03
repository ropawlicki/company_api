# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :company, null: false, foreign_key: true
      t.string :street, null: false
      t.string :city, null: false
      t.string :postal_code
      t.string :country, null: false

      t.timestamps
    end
  end
end
