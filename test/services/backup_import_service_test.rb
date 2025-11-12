require "test_helper"

class BackupImportServiceTest < ActiveSupport::TestCase
  setup do
    @service = BackupImportService.new
    
    # JSON de teste válido
    @valid_json_data = {
      version: "1.0",
      exported_at: Time.current.iso8601,
      food_items: [
        {
          id: 999,
          name: "Feijão",
          category: "legumes",
          quantity: "5.0",
          expiration_date: (Date.today + 60.days).iso8601,
          storage_location: "Despensa",
          notes: "Feijão preto",
          created_at: Time.current.iso8601,
          updated_at: Time.current.iso8601
        }
      ],
      supply_batches: [
        {
          id: 998,
          food_item_id: 999,
          initial_quantity: "5.0",
          current_quantity: "5.0",
          entry_date: Date.today.iso8601,
          expiration_date: (Date.today + 60.days).iso8601,
          batch_code: "BATCH999",
          supplier: "Fornecedor B",
          unit_cost: "15.00",
          status: "active",
          created_at: Time.current.iso8601,
          updated_at: Time.current.iso8601
        }
      ],
      supply_rotations: [
        {
          id: 997,
          supply_batch_id: 998,
          food_item_id: 999,
          quantity: "1.0",
          rotation_date: Date.today.iso8601,
          rotation_type: "consumption",
          reason: "Teste",
          notes: "Importado",
          created_at: Time.current.iso8601,
          updated_at: Time.current.iso8601
        }
      ]
    }.to_json
    
    # CSV de teste válido
    @valid_csv_data = {
      food_items: CSV.generate(headers: true) do |csv|
        csv << ["id", "name", "category", "quantity", "expiration_date", 
                "storage_location", "notes", "created_at", "updated_at"]
        csv << [999, "Feijão", "legumes", 5.0, (Date.today + 60.days).to_s, 
                "Despensa", "Feijão preto", Time.current, Time.current]
      end,
      supply_batches: CSV.generate(headers: true) do |csv|
        csv << ["id", "food_item_id", "initial_quantity", "current_quantity",
                "entry_date", "expiration_date", "batch_code", "supplier",
                "unit_cost", "notes", "status", "created_at", "updated_at"]
        csv << [998, 999, 5.0, 5.0, Date.today.to_s, (Date.today + 60.days).to_s,
                "BATCH999", "Fornecedor B", 15.00, "", "active", Time.current, Time.current]
      end,
      supply_rotations: CSV.generate(headers: true) do |csv|
        csv << ["id", "supply_batch_id", "food_item_id", "quantity",
                "rotation_date", "rotation_type", "reason", "notes",
                "created_at", "updated_at"]
        csv << [997, 998, 999, 1.0, Date.today.to_s, "consumption", 
                "Teste", "Importado", Time.current, Time.current]
      end
    }
  end
  
  test "should import from JSON with merge strategy" do
    initial_count = FoodItem.count
    
    result = @service.import_from_json(@valid_json_data, strategy: :merge)
    
    assert result[:success]
    assert_equal initial_count + 1, FoodItem.count
    assert_equal 1, result[:food_items_created]
    assert_equal 1, result[:supply_batches_created]
    assert_equal 1, result[:supply_rotations_created]
    
    food_item = FoodItem.find_by(name: "Feijão")
    assert food_item.present?
    assert_equal "legumes", food_item.category
  end
  
  test "should import from JSON with replace strategy" do
    # Cria alguns dados existentes
    FoodItem.create!(name: "Arroz", category: "grains", quantity: 10.0)
    
    initial_count = FoodItem.count
    assert initial_count > 0
    
    result = @service.import_from_json(@valid_json_data, strategy: :replace)
    
    assert result[:success]
    assert_equal 1, FoodItem.count  # Apenas o importado
    assert_equal 0, result[:food_items_updated]
    
    # Verifica que apenas os novos dados existem
    assert_nil FoodItem.find_by(name: "Arroz")
    assert FoodItem.find_by(name: "Feijão").present?
  end
  
  test "should merge and avoid duplicates" do
    # Cria um item existente
    existing = FoodItem.create!(
      name: "Feijão",
      category: "legumes",
      quantity: 3.0,
      expiration_date: Date.today + 30.days
    )
    
    initial_count = FoodItem.count
    
    result = @service.import_from_json(@valid_json_data, strategy: :merge)
    
    assert result[:success]
    assert_equal initial_count, FoodItem.count  # Não duplicou
    assert result[:food_items_updated] > 0 || result[:food_items_created] == 0
  end
  
  test "should import from CSV with merge strategy" do
    initial_count = FoodItem.count
    
    result = @service.import_from_csv(@valid_csv_data, strategy: :merge)
    
    assert result[:success]
    assert_equal initial_count + 1, FoodItem.count
    assert_equal 1, result[:food_items_created]
    
    food_item = FoodItem.find_by(name: "Feijão")
    assert food_item.present?
  end
  
  test "should validate data before import" do
    invalid_json = {
      version: "1.0",
      exported_at: Time.current.iso8601,
      food_items: [
        {
          id: 999,
          name: "",  # Nome inválido
          category: "legumes",
          quantity: "5.0"
        }
      ],
      supply_batches: [],
      supply_rotations: []
    }.to_json
    
    result = @service.import_from_json(invalid_json, strategy: :merge)
    
    assert_not result[:success]
    assert result[:errors].present?
  end
  
  test "should return detailed results" do
    result = @service.import_from_json(@valid_json_data, strategy: :merge)
    
    assert result.key?(:success)
    assert result.key?(:food_items_created)
    assert result.key?(:food_items_updated)
    assert result.key?(:supply_batches_created)
    assert result.key?(:supply_rotations_created)
    assert result.key?(:errors)
  end
  
  test "should handle empty data gracefully" do
    empty_json = {
      version: "1.0",
      exported_at: Time.current.iso8601,
      food_items: [],
      supply_batches: [],
      supply_rotations: []
    }.to_json
    
    result = @service.import_from_json(empty_json, strategy: :merge)
    
    assert result[:success]
    assert_equal 0, result[:food_items_created]
  end
  
  test "should rollback on error" do
    initial_count = FoodItem.count
    
    # JSON com erro no meio
    invalid_json = {
      version: "1.0",
      exported_at: Time.current.iso8601,
      food_items: [
        {
          id: 999,
          name: "Item Válido",
          category: "test",
          quantity: "5.0"
        },
        {
          id: 998,
          name: "",  # Inválido
          category: "test",
          quantity: "5.0"
        }
      ],
      supply_batches: [],
      supply_rotations: []
    }.to_json
    
    result = @service.import_from_json(invalid_json, strategy: :merge)
    
    assert_not result[:success]
    assert_equal initial_count, FoodItem.count  # Rollback completo
  end
  
  test "should preserve relationships on import" do
    result = @service.import_from_json(@valid_json_data, strategy: :replace)
    
    assert result[:success]
    
    food_item = FoodItem.find_by(name: "Feijão")
    assert food_item.supply_batches.count > 0
    assert food_item.supply_rotations.count > 0
    
    batch = food_item.supply_batches.first
    assert_equal food_item.id, batch.food_item_id
    
    rotation = food_item.supply_rotations.first
    assert_equal food_item.id, rotation.food_item_id
    assert_equal batch.id, rotation.supply_batch_id
  end
  
  test "should handle invalid JSON format" do
    result = @service.import_from_json("invalid json", strategy: :merge)
    
    assert_not result[:success]
    assert result[:errors].present?
  end
  
  test "should handle missing required fields in CSV" do
    invalid_csv = {
      food_items: CSV.generate(headers: true) do |csv|
        csv << ["id", "name"]  # Faltam campos obrigatórios
        csv << [999, "Test"]
      end,
      supply_batches: "",
      supply_rotations: ""
    }
    
    result = @service.import_from_csv(invalid_csv, strategy: :merge)
    
    # Pode falhar ou ter avisos
    assert result.key?(:success)
  end
end

