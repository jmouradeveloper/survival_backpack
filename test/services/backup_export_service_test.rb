require "test_helper"

class BackupExportServiceTest < ActiveSupport::TestCase
  setup do
    # Cria dados de teste
    @food_item = FoodItem.create!(
      name: "Arroz",
      category: "grains",
      quantity: 10.0,
      expiration_date: Date.today + 30.days,
      storage_location: "Despensa",
      notes: "Arroz integral"
    )
    
    @supply_batch = SupplyBatch.create!(
      food_item: @food_item,
      initial_quantity: 5.0,
      current_quantity: 5.0,
      entry_date: Date.today,
      expiration_date: Date.today + 30.days,
      batch_code: "BATCH001",
      supplier: "Fornecedor A",
      unit_cost: 10.50,
      status: "active"
    )
    
    @supply_rotation = SupplyRotation.create!(
      supply_batch: @supply_batch,
      food_item: @food_item,
      quantity: 2.0,
      rotation_date: Date.today,
      rotation_type: "consumption",
      reason: "Consumo normal",
      notes: "Teste de rotação"
    )
    
    @service = BackupExportService.new
  end
  
  test "should export data to JSON format" do
    result = @service.export_to_json
    
    assert result.present?
    
    data = JSON.parse(result)
    assert data.key?("version")
    assert data.key?("exported_at")
    assert data.key?("food_items")
    assert data.key?("supply_batches")
    assert data.key?("supply_rotations")
    
    assert_equal 1, data["food_items"].length
    assert_equal @food_item.name, data["food_items"].first["name"]
    
    assert_equal 1, data["supply_batches"].length
    assert_equal @supply_batch.batch_code, data["supply_batches"].first["batch_code"]
    
    assert_equal 1, data["supply_rotations"].length
    assert_equal @supply_rotation.rotation_type, data["supply_rotations"].first["rotation_type"]
  end
  
  test "should export data to CSV format" do
    result = @service.export_to_csv
    
    assert result.present?
    assert result.is_a?(Hash)
    assert result.key?(:food_items)
    assert result.key?(:supply_batches)
    assert result.key?(:supply_rotations)
    
    # Verifica CSV de food_items
    food_items_csv = result[:food_items]
    assert food_items_csv.include?("name")
    assert food_items_csv.include?("Arroz")
    
    # Verifica CSV de supply_batches
    supply_batches_csv = result[:supply_batches]
    assert supply_batches_csv.include?("batch_code")
    assert supply_batches_csv.include?("BATCH001")
    
    # Verifica CSV de supply_rotations
    supply_rotations_csv = result[:supply_rotations]
    assert supply_rotations_csv.include?("rotation_type")
    assert supply_rotations_csv.include?("consumption")
  end
  
  test "should include metadata in JSON export" do
    result = @service.export_to_json
    data = JSON.parse(result)
    
    assert data["version"].present?
    assert data["exported_at"].present?
    assert Time.parse(data["exported_at"]) <= Time.current
  end
  
  test "should export empty data when no records exist" do
    FoodItem.destroy_all
    SupplyBatch.destroy_all
    SupplyRotation.destroy_all
    
    result = @service.export_to_json
    data = JSON.parse(result)
    
    assert_equal 0, data["food_items"].length
    assert_equal 0, data["supply_batches"].length
    assert_equal 0, data["supply_rotations"].length
  end
  
  test "should preserve relationships in JSON export" do
    result = @service.export_to_json
    data = JSON.parse(result)
    
    food_item_data = data["food_items"].first
    supply_batch_data = data["supply_batches"].first
    supply_rotation_data = data["supply_rotations"].first
    
    assert_equal food_item_data["id"], supply_batch_data["food_item_id"]
    assert_equal food_item_data["id"], supply_rotation_data["food_item_id"]
    assert_equal supply_batch_data["id"], supply_rotation_data["supply_batch_id"]
  end
  
  test "should export all food item attributes" do
    result = @service.export_to_json
    data = JSON.parse(result)
    food_item_data = data["food_items"].first
    
    assert_equal @food_item.id, food_item_data["id"]
    assert_equal @food_item.name, food_item_data["name"]
    assert_equal @food_item.category, food_item_data["category"]
    assert_equal @food_item.quantity.to_s, food_item_data["quantity"].to_s
    assert_equal @food_item.storage_location, food_item_data["storage_location"]
    assert_equal @food_item.notes, food_item_data["notes"]
  end
  
  test "should handle dates correctly in JSON export" do
    result = @service.export_to_json
    data = JSON.parse(result)
    food_item_data = data["food_items"].first
    
    assert food_item_data["expiration_date"].present?
    assert Date.parse(food_item_data["expiration_date"])
  end
  
  test "should generate valid CSV headers" do
    result = @service.export_to_csv
    
    food_items_csv = result[:food_items]
    headers = food_items_csv.lines.first.strip.split(",")
    
    assert headers.include?("id")
    assert headers.include?("name")
    assert headers.include?("category")
    assert headers.include?("quantity")
  end
end

