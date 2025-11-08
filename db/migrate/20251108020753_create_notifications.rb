class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :food_item, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.string :notification_type, null: false, default: 'expiration_warning'
      t.boolean :read, default: false, null: false
      t.datetime :sent_at
      t.datetime :scheduled_for
      t.integer :priority, default: 0 # 0: baixa, 1: média, 2: alta

      t.timestamps
    end
    
    add_index :notifications, :read
    add_index :notifications, :scheduled_for
    add_index :notifications, :notification_type
  end
end
