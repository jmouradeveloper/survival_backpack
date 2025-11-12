require "test_helper"

class FoodItemTest < ActiveSupport::TestCase
  # === TESTES DE VALIDAÇÃO ===
  
  test "should be valid with valid attributes" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "Arroz",
      category: "grains",
      quantity: 5.0,
      expiration_date: 30.days.from_now
    )
    assert food_item.valid?
  end
  
  test "should require name" do
    food_item = FoodItem.new(
      user: regular_user,
      category: "grains",
      quantity: 5.0
    )
    assert_not food_item.valid?
    assert food_item.errors[:name].any?
  end
  
  test "should require name with minimum length" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "A",
      category: "grains",
      quantity: 5.0
    )
    assert_not food_item.valid?
    assert food_item.errors[:name].any?
  end
  
  test "should not allow name longer than 255 characters" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "a" * 256,
      category: "grains",
      quantity: 5.0
    )
    assert_not food_item.valid?
    assert food_item.errors[:name].any?
  end
  
  test "should require category" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "Arroz",
      quantity: 5.0
    )
    assert_not food_item.valid?
    assert food_item.errors[:category].any?
  end
  
  test "should require quantity" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "Arroz",
      category: "grains"
    )
    assert_not food_item.valid?
    assert food_item.errors[:quantity].any?
  end
  
  test "should require quantity to be non-negative" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "Arroz",
      category: "grains",
      quantity: -1.0
    )
    assert_not food_item.valid?
    assert food_item.errors[:quantity].any?
  end
  
  test "should allow quantity to be zero" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "Arroz",
      category: "grains",
      quantity: 0
    )
    assert food_item.valid?
  end
  
  test "should not allow storage_location longer than 255 characters" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "Arroz",
      category: "grains",
      quantity: 5.0,
      storage_location: "a" * 256
    )
    assert_not food_item.valid?
    assert food_item.errors[:storage_location].any?
  end
  
  test "should not allow notes longer than 5000 characters" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "Arroz",
      category: "grains",
      quantity: 5.0,
      notes: "a" * 5001
    )
    assert_not food_item.valid?
    assert food_item.errors[:notes].any?
  end
  
  test "should not allow past expiration date" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "Arroz",
      category: "grains",
      quantity: 5.0,
      expiration_date: 1.day.ago
    )
    assert_not food_item.valid?
    assert food_item.errors[:expiration_date].present?
  end
  
  test "should allow today as expiration date" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "Arroz",
      category: "grains",
      quantity: 5.0,
      expiration_date: Date.today
    )
    assert food_item.valid?
  end
  
  test "should allow nil expiration date" do
    food_item = FoodItem.new(
      user: regular_user,
      name: "Arroz",
      category: "grains",
      quantity: 5.0,
      expiration_date: nil
    )
    assert food_item.valid?
  end
  
  # === TESTES DE ASSOCIAÇÕES ===
  
  test "should have many notifications" do
    food_item = food_items(:rice)
    assert_respond_to food_item, :notifications
  end
  
  test "should have many supply_batches" do
    food_item = food_items(:rice)
    assert_respond_to food_item, :supply_batches
  end
  
  test "should have many supply_rotations" do
    food_item = food_items(:rice)
    assert_respond_to food_item, :supply_rotations
  end
  
  test "should destroy associated records when destroyed" do
    food_item = food_items(:rice)
    batch_ids = food_item.supply_batches.pluck(:id)
    
    food_item.destroy
    
    batch_ids.each do |batch_id|
      assert_nil SupplyBatch.find_by(id: batch_id)
    end
  end
  
  # === TESTES DE SCOPES ===
  
  test "by_category scope should filter by category" do
    grains = FoodItem.by_category("grains")
    assert grains.all? { |item| item.category == "grains" }
    assert_includes grains, food_items(:rice)
  end
  
  test "expiring_soon scope should return items expiring within 7 days" do
    expiring = FoodItem.expiring_soon
    assert_includes expiring, food_items(:beans) # expira em 5 dias
    assert_not_includes expiring, food_items(:rice) # expira em 30 dias
  end
  
  test "expiring_soon scope should accept custom days parameter" do
    expiring = FoodItem.expiring_soon(10)
    assert_includes expiring, food_items(:beans) # expira em 5 dias
    assert_includes expiring, food_items(:chocolate) # expira em 7 dias
  end
  
  test "expired scope should return only expired items" do
    expired = FoodItem.expired
    assert_includes expired, food_items(:expired_milk)
    assert_not_includes expired, food_items(:rice)
    assert_not_includes expired, food_items(:beans)
  end
  
  test "valid_items scope should return non-expired items" do
    valid = FoodItem.valid_items
    assert_includes valid, food_items(:rice)
    assert_includes valid, food_items(:beans)
    assert_includes valid, food_items(:salt) # sem data de validade
    assert_not_includes valid, food_items(:expired_milk)
  end
  
  test "by_storage_location scope should filter by location" do
    despensa = FoodItem.by_storage_location("Despensa")
    assert despensa.all? { |item| item.storage_location == "Despensa" }
    assert_includes despensa, food_items(:rice)
  end
  
  test "recent scope should order by created_at desc" do
    recent = FoodItem.recent
    assert_equal recent.first.created_at >= recent.last.created_at, true
  end
  
  # === TESTES DE MÉTODOS DE INSTÂNCIA ===
  
  test "expired? should return true for expired items" do
    assert food_items(:expired_milk).expired?
  end
  
  test "expired? should return false for valid items" do
    assert_not food_items(:rice).expired?
  end
  
  test "expired? should return false for items without expiration date" do
    assert_not food_items(:salt).expired?
  end
  
  test "expiring_soon? should return true for items expiring within 7 days" do
    assert food_items(:beans).expiring_soon?
  end
  
  test "expiring_soon? should return false for items expiring later" do
    assert_not food_items(:rice).expiring_soon?
  end
  
  test "expiring_soon? should return false for expired items" do
    assert_not food_items(:expired_milk).expiring_soon?
  end
  
  test "expiring_soon? should accept custom days parameter" do
    assert food_items(:beans).expiring_soon?(10)
    assert_not food_items(:rice).expiring_soon?(10)
  end
  
  test "days_until_expiration should return correct number of days" do
    rice = food_items(:rice)
    expected_days = (rice.expiration_date - Date.today).to_i
    assert_equal expected_days, rice.days_until_expiration
  end
  
  test "days_until_expiration should return nil for items without expiration date" do
    assert_nil food_items(:salt).days_until_expiration
  end
  
  test "days_until_expiration should return negative for expired items" do
    expired = food_items(:expired_milk)
    assert expired.days_until_expiration < 0
  end
  
  test "status should return :expired for expired items" do
    assert_equal :expired, food_items(:expired_milk).status
  end
  
  test "status should return :expiring_soon for items expiring soon" do
    assert_equal :expiring_soon, food_items(:beans).status
  end
  
  test "status should return :valid for valid items" do
    assert_equal :valid, food_items(:rice).status
  end
  
  # === TESTES DE MÉTODOS FIFO ===
  
  test "active_batches should return only active batches ordered by FIFO" do
    rice = food_items(:rice)
    batches = rice.active_batches.to_a
    
    assert batches.all? { |b| b.status == 'active' }
    # Verifica que o batch mais antigo vem primeiro
    assert_equal supply_batches(:rice_batch_2).id, batches.first.id
  end
  
  test "next_batch_to_consume should return oldest active batch" do
    rice = food_items(:rice)
    next_batch = rice.next_batch_to_consume
    
    # rice_batch_2 é mais antigo que rice_batch_1
    assert_equal supply_batches(:rice_batch_2).id, next_batch.id
  end
  
  test "total_batch_quantity should sum all active batches" do
    rice = food_items(:rice)
    # rice_batch_1: 3.0, rice_batch_2: 2.0
    assert_equal 5.0, rice.total_batch_quantity
  end
  
  test "consume_fifo! should consume from oldest batch first" do
    rice = food_items(:rice)
    initial_oldest_quantity = supply_batches(:rice_batch_2).current_quantity
    
    rotations = rice.consume_fifo!(1.0, rotation_type: 'consumption')
    
    assert_equal 1, rotations.size
    supply_batches(:rice_batch_2).reload
    assert_equal initial_oldest_quantity - 1.0, supply_batches(:rice_batch_2).current_quantity
  end
  
  test "consume_fifo! should consume from multiple batches if needed" do
    rice = food_items(:rice)
    
    # Consome mais que o batch mais antigo (rice_batch_2 tem 2.0)
    rotations = rice.consume_fifo!(3.0, rotation_type: 'consumption')
    
    assert_equal 2, rotations.size
    supply_batches(:rice_batch_2).reload
    supply_batches(:rice_batch_1).reload
    
    # rice_batch_2 deve estar zerado
    assert_equal 0, supply_batches(:rice_batch_2).current_quantity
    # rice_batch_1 deve ter perdido 1.0 (3.0 total - 2.0 do batch_2)
    assert_equal 2.0, supply_batches(:rice_batch_1).current_quantity
  end
  
  test "consume_fifo! should raise error for zero or negative quantity" do
    rice = food_items(:rice)
    
    assert_raises(ArgumentError, "Quantity must be positive") do
      rice.consume_fifo!(0)
    end
    
    assert_raises(ArgumentError, "Quantity must be positive") do
      rice.consume_fifo!(-1.0)
    end
  end
  
  test "consume_fifo! should raise error for insufficient quantity" do
    rice = food_items(:rice)
    total = rice.total_batch_quantity
    
    assert_raises(ArgumentError, "Insufficient quantity available") do
      rice.consume_fifo!(total + 1.0)
    end
  end
  
  test "consume_fifo! should accept rotation_type and notes" do
    rice = food_items(:rice)
    
    rotations = rice.consume_fifo!(
      1.0, 
      rotation_type: 'waste', 
      reason: 'damaged',
      notes: 'Package was damaged'
    )
    
    rotation = rotations.first
    assert_equal 'waste', rotation.rotation_type
    assert_equal 'damaged', rotation.reason
    assert_equal 'Package was damaged', rotation.notes
  end
  
  test "batch_statistics should return correct statistics" do
    rice = food_items(:rice)
    stats = rice.batch_statistics
    
    assert_equal 2, stats[:total_batches]
    assert_equal 2, stats[:active_batches]
    assert_equal 0, stats[:depleted_batches]
    assert_equal 5.0, stats[:total_quantity]
    assert_not_nil stats[:oldest_batch_date]
    assert_not_nil stats[:next_expiration_date]
  end
  
  # === TESTES DE SERIALIZAÇÃO ===
  
  test "as_json should include custom methods" do
    rice = food_items(:rice)
    json = rice.as_json
    
    assert_includes json.keys, "expired?"
    assert_includes json.keys, "expiring_soon?"
    assert_includes json.keys, "days_until_expiration"
    assert_includes json.keys, "status"
  end
  
  test "as_json should return correct values" do
    rice = food_items(:rice)
    json = rice.as_json
    
    assert_equal false, json["expired?"]
    assert_equal false, json["expiring_soon?"]
    assert_equal "valid", json["status"]
    assert_kind_of Integer, json["days_until_expiration"]
  end
end

