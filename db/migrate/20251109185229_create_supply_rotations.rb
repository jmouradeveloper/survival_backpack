class CreateSupplyRotations < ActiveRecord::Migration[8.0]
  def change
    create_table :supply_rotations do |t|
      t.references :supply_batch, null: false, foreign_key: true
      t.references :food_item, null: false, foreign_key: true
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.date :rotation_date, null: false
      t.string :rotation_type, null: false # consumption, waste, donation, transfer
      t.string :reason
      t.text :notes
      
      t.timestamps
    end

    add_index :supply_rotations, :rotation_date
    add_index :supply_rotations, :rotation_type
    add_index :supply_rotations, [:food_item_id, :rotation_date]
  end
end
