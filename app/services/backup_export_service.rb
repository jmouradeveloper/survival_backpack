require 'csv'
require 'json'

class BackupExportService
  BACKUP_VERSION = "1.0"
  
  attr_reader :user
  
  def initialize(user)
    @user = user
  end
  
  def export_to_json
    data = {
      version: BACKUP_VERSION,
      exported_at: Time.current.iso8601,
      food_items: export_food_items,
      supply_batches: export_supply_batches,
      supply_rotations: export_supply_rotations
    }
    
    JSON.pretty_generate(data)
  end
  
  def export_to_csv
    {
      food_items: generate_food_items_csv,
      supply_batches: generate_supply_batches_csv,
      supply_rotations: generate_supply_rotations_csv
    }
  end
  
  private
  
  def export_food_items
    user.food_items.map do |food_item|
      {
        id: food_item.id,
        name: food_item.name,
        category: food_item.category,
        quantity: food_item.quantity.to_s,
        expiration_date: food_item.expiration_date&.iso8601,
        storage_location: food_item.storage_location,
        notes: food_item.notes,
        created_at: food_item.created_at.iso8601,
        updated_at: food_item.updated_at.iso8601
      }
    end
  end
  
  def export_supply_batches
    SupplyBatch.joins(:food_item).where(food_items: { user_id: user.id }).map do |batch|
      {
        id: batch.id,
        food_item_id: batch.food_item_id,
        initial_quantity: batch.initial_quantity.to_s,
        current_quantity: batch.current_quantity.to_s,
        entry_date: batch.entry_date.iso8601,
        expiration_date: batch.expiration_date&.iso8601,
        batch_code: batch.batch_code,
        supplier: batch.supplier,
        unit_cost: batch.unit_cost&.to_s,
        notes: batch.notes,
        status: batch.status,
        created_at: batch.created_at.iso8601,
        updated_at: batch.updated_at.iso8601
      }
    end
  end
  
  def export_supply_rotations
    SupplyRotation.joins(:food_item).where(food_items: { user_id: user.id }).map do |rotation|
      {
        id: rotation.id,
        supply_batch_id: rotation.supply_batch_id,
        food_item_id: rotation.food_item_id,
        quantity: rotation.quantity.to_s,
        rotation_date: rotation.rotation_date.iso8601,
        rotation_type: rotation.rotation_type,
        reason: rotation.reason,
        notes: rotation.notes,
        created_at: rotation.created_at.iso8601,
        updated_at: rotation.updated_at.iso8601
      }
    end
  end
  
  def generate_food_items_csv
    CSV.generate(headers: true) do |csv|
      csv << ["id", "name", "category", "quantity", "expiration_date", 
              "storage_location", "notes", "created_at", "updated_at"]
      
      user.food_items.each do |food_item|
        csv << [
          food_item.id,
          food_item.name,
          food_item.category,
          food_item.quantity,
          food_item.expiration_date,
          food_item.storage_location,
          food_item.notes,
          food_item.created_at,
          food_item.updated_at
        ]
      end
    end
  end
  
  def generate_supply_batches_csv
    CSV.generate(headers: true) do |csv|
      csv << ["id", "food_item_id", "initial_quantity", "current_quantity",
              "entry_date", "expiration_date", "batch_code", "supplier",
              "unit_cost", "notes", "status", "created_at", "updated_at"]
      
      SupplyBatch.joins(:food_item).where(food_items: { user_id: user.id }).each do |batch|
        csv << [
          batch.id,
          batch.food_item_id,
          batch.initial_quantity,
          batch.current_quantity,
          batch.entry_date,
          batch.expiration_date,
          batch.batch_code,
          batch.supplier,
          batch.unit_cost,
          batch.notes,
          batch.status,
          batch.created_at,
          batch.updated_at
        ]
      end
    end
  end
  
  def generate_supply_rotations_csv
    CSV.generate(headers: true) do |csv|
      csv << ["id", "supply_batch_id", "food_item_id", "quantity",
              "rotation_date", "rotation_type", "reason", "notes",
              "created_at", "updated_at"]
      
      SupplyRotation.joins(:food_item).where(food_items: { user_id: user.id }).each do |rotation|
        csv << [
          rotation.id,
          rotation.supply_batch_id,
          rotation.food_item_id,
          rotation.quantity,
          rotation.rotation_date,
          rotation.rotation_type,
          rotation.reason,
          rotation.notes,
          rotation.created_at,
          rotation.updated_at
        ]
      end
    end
  end
end

