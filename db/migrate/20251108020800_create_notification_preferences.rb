class CreateNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_preferences do |t|
      t.integer :days_before_expiration, default: 7, null: false
      t.boolean :enable_push_notifications, default: true, null: false
      t.boolean :enable_email_notifications, default: false, null: false
      t.datetime :last_checked_at
      t.string :push_subscription_endpoint
      t.text :push_subscription_keys # Armazena as chaves de criptografia para push

      t.timestamps
    end
  end
end
