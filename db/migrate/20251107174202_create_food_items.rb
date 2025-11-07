class CreateFoodItems < ActiveRecord::Migration[8.0]
  def change
    create_table :food_items do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.decimal :quantity, precision: 10, scale: 2, null: false, default: 0
      t.date :expiration_date
      t.string :storage_location
      t.text :notes

      t.timestamps
    end

    add_index :food_items, :name
    add_index :food_items, :category
    add_index :food_items, :expiration_date
  end
end
