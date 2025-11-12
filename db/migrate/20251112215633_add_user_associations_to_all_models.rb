class AddUserAssociationsToAllModels < ActiveRecord::Migration[8.0]
  def up
    # Add user_id columns as nullable first
    add_reference :food_items, :user, foreign_key: true
    add_reference :supply_batches, :user, foreign_key: true
    add_reference :supply_rotations, :user, foreign_key: true
    add_reference :notifications, :user, foreign_key: true
    add_reference :notification_preferences, :user, foreign_key: true
    
    # Create a default admin user if no users exist
    if User.count == 0
      default_user = User.create!(
        email: "admin@example.com",
        password: "Admin@123",
        password_confirmation: "Admin@123",
        role: :admin
      )
      
      puts "Created default admin user: admin@example.com / Admin@123"
      puts "IMPORTANT: Please change this password after first login!"
      
      # Associate all existing records with the default user
      FoodItem.update_all(user_id: default_user.id)
      SupplyBatch.update_all(user_id: default_user.id)
      SupplyRotation.update_all(user_id: default_user.id)
      Notification.update_all(user_id: default_user.id)
      NotificationPreference.update_all(user_id: default_user.id)
    end
    
    # Now make the columns non-nullable
    change_column_null :food_items, :user_id, false
    change_column_null :supply_batches, :user_id, false
    change_column_null :supply_rotations, :user_id, false
    change_column_null :notifications, :user_id, false
    change_column_null :notification_preferences, :user_id, false
  end
  
  def down
    remove_reference :food_items, :user, foreign_key: true
    remove_reference :supply_batches, :user, foreign_key: true
    remove_reference :supply_rotations, :user, foreign_key: true
    remove_reference :notifications, :user, foreign_key: true
    remove_reference :notification_preferences, :user, foreign_key: true
  end
end
