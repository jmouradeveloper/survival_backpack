class CreateSupplyBatches < ActiveRecord::Migration[8.0]
  def change
    create_table :supply_batches do |t|
      t.references :food_item, null: false, foreign_key: true
      t.decimal :initial_quantity, precision: 10, scale: 2, null: false
      t.decimal :current_quantity, precision: 10, scale: 2, null: false
      t.date :entry_date, null: false
      t.date :expiration_date
      t.string :batch_code
      t.string :supplier
      t.decimal :unit_cost, precision: 10, scale: 2
      t.text :notes
      t.string :status, default: 'active', null: false # active, depleted, expired
      
      t.timestamps
    end

    add_index :supply_batches, :food_item_id
    add_index :supply_batches, :entry_date
    add_index :supply_batches, :expiration_date
    add_index :supply_batches, :status
    add_index :supply_batches, :batch_code
  end
end
