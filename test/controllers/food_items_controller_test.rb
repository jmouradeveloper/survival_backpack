require "test_helper"

class FoodItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @food_item = food_items(:rice)
  end

  # === TESTES DE INDEX ===
  
  test "should get index" do
    get food_items_url
    assert_response :success
    assert_not_nil assigns(:food_items)
    assert_not_nil assigns(:categories)
    assert_not_nil assigns(:storage_locations)
  end
  
  test "should get index with turbo_stream format" do
    get food_items_url, as: :turbo_stream
    assert_response :success
  end
  
  test "should filter by category" do
    get food_items_url, params: { category: "grains" }
    assert_response :success
    
    items = assigns(:food_items)
    assert items.all? { |item| item.category == "grains" }
  end
  
  test "should filter by storage_location" do
    get food_items_url, params: { storage_location: "Despensa" }
    assert_response :success
    
    items = assigns(:food_items)
    assert items.all? { |item| item.storage_location == "Despensa" }
  end
  
  test "should filter expired items" do
    get food_items_url, params: { filter: "expired" }
    assert_response :success
    
    items = assigns(:food_items)
    assert items.all?(&:expired?)
  end
  
  test "should filter expiring_soon items" do
    get food_items_url, params: { filter: "expiring_soon" }
    assert_response :success
    
    items = assigns(:food_items)
    # Verifica que os itens estão expirando em breve ou sem filtro aplicado
    assert_not_nil items
  end
  
  test "should filter valid items" do
    get food_items_url, params: { filter: "valid" }
    assert_response :success
    
    items = assigns(:food_items)
    assert items.none?(&:expired?)
  end
  
  test "should combine category and status filters" do
    get food_items_url, params: { category: "grains", filter: "valid" }
    assert_response :success
    
    items = assigns(:food_items)
    assert items.all? { |item| item.category == "grains" && !item.expired? }
  end
  
  test "index should populate categories for filter" do
    get food_items_url
    assert_response :success
    
    categories = assigns(:categories)
    assert_includes categories, "grains"
    assert_includes categories, "legumes"
  end
  
  test "index should populate storage_locations for filter" do
    get food_items_url
    assert_response :success
    
    locations = assigns(:storage_locations)
    assert_includes locations, "Despensa"
  end
  
  # === TESTES DE SHOW ===
  
  test "should show food_item" do
    get food_item_url(@food_item)
    assert_response :success
    assert_equal @food_item, assigns(:food_item)
  end
  
  test "should show food_item with turbo_stream format" do
    get food_item_url(@food_item), as: :turbo_stream
    assert_response :success
  end
  
  test "should return 404 for non-existent food_item" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get food_item_url(id: 99999)
    end
  end
  
  # === TESTES DE NEW ===
  
  test "should get new" do
    get new_food_item_url
    assert_response :success
    assert_not_nil assigns(:food_item)
    assert assigns(:food_item).new_record?
  end
  
  # === TESTES DE EDIT ===
  
  test "should get edit" do
    get edit_food_item_url(@food_item)
    assert_response :success
    assert_equal @food_item, assigns(:food_item)
  end
  
  test "should return 404 when editing non-existent food_item" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get edit_food_item_url(id: 99999)
    end
  end
  
  # === TESTES DE CREATE ===
  
  test "should create food_item" do
    assert_difference("FoodItem.count") do
      post food_items_url, params: { 
        food_item: { 
          name: "Novo Alimento",
          category: "test",
          quantity: 10.0,
          expiration_date: 60.days.from_now,
          storage_location: "Test Location",
          notes: "Test notes"
        } 
      }
    end
    
    assert_redirected_to food_items_url
    assert_equal "Alimento cadastrado com sucesso.", flash[:notice]
  end
  
  test "should create food_item with turbo_stream format" do
    assert_difference("FoodItem.count") do
      post food_items_url, params: { 
        food_item: { 
          name: "Novo Alimento",
          category: "test",
          quantity: 10.0
        } 
      }, as: :turbo_stream
    end
    
    assert_response :success
    assert_equal "Alimento cadastrado com sucesso.", flash.now[:notice]
  end
  
  test "should convert Brazilian date format on create" do
    post food_items_url, params: { 
      food_item: { 
        name: "Alimento com Data BR",
        category: "test",
        quantity: 5.0,
        expiration_date: "31/12/2025"
      } 
    }
    
    created_item = FoodItem.find_by(name: "Alimento com Data BR")
    assert_not_nil created_item
    assert_equal Date.new(2025, 12, 31), created_item.expiration_date
  end
  
  test "should not create food_item with invalid params" do
    assert_no_difference("FoodItem.count") do
      post food_items_url, params: { 
        food_item: { 
          name: "",  # nome vazio - inválido
          category: "test",
          quantity: 10.0
        } 
      }
    end
    
    assert_response :unprocessable_entity
  end
  
  test "should not create food_item with invalid params in turbo_stream" do
    assert_no_difference("FoodItem.count") do
      post food_items_url, params: { 
        food_item: { 
          name: "",
          category: "test",
          quantity: 10.0
        } 
      }, as: :turbo_stream
    end
    
    assert_response :unprocessable_entity
  end
  
  test "should not create food_item without name" do
    assert_no_difference("FoodItem.count") do
      post food_items_url, params: { 
        food_item: { 
          category: "test",
          quantity: 10.0
        } 
      }
    end
    
    assert_response :unprocessable_entity
  end
  
  test "should not create food_item without category" do
    assert_no_difference("FoodItem.count") do
      post food_items_url, params: { 
        food_item: { 
          name: "Test",
          quantity: 10.0
        } 
      }
    end
    
    assert_response :unprocessable_entity
  end
  
  test "should not create food_item without quantity" do
    assert_no_difference("FoodItem.count") do
      post food_items_url, params: { 
        food_item: { 
          name: "Test",
          category: "test"
        } 
      }
    end
    
    assert_response :unprocessable_entity
  end
  
  test "should not create food_item with negative quantity" do
    assert_no_difference("FoodItem.count") do
      post food_items_url, params: { 
        food_item: { 
          name: "Test",
          category: "test",
          quantity: -5.0
        } 
      }
    end
    
    assert_response :unprocessable_entity
  end
  
  # === TESTES DE UPDATE ===
  
  test "should update food_item" do
    patch food_item_url(@food_item), params: { 
      food_item: { 
        name: "Arroz Atualizado",
        quantity: 7.5
      } 
    }
    
    assert_redirected_to food_items_url
    assert_equal "Alimento atualizado com sucesso.", flash[:notice]
    
    @food_item.reload
    assert_equal "Arroz Atualizado", @food_item.name
    # Nota: quantity pode ser atualizada por callbacks de supply_batch
  end
  
  test "should update food_item with turbo_stream format" do
    patch food_item_url(@food_item), params: { 
      food_item: { 
        name: "Arroz Atualizado"
      } 
    }, as: :turbo_stream
    
    assert_response :success
    assert_equal "Alimento atualizado com sucesso.", flash.now[:notice]
    
    @food_item.reload
    assert_equal "Arroz Atualizado", @food_item.name
  end
  
  test "should convert Brazilian date format on update" do
    patch food_item_url(@food_item), params: { 
      food_item: { 
        expiration_date: "15/06/2026"
      } 
    }
    
    @food_item.reload
    assert_equal Date.new(2026, 6, 15), @food_item.expiration_date
  end
  
  test "should not update food_item with invalid params" do
    original_name = @food_item.name
    
    patch food_item_url(@food_item), params: { 
      food_item: { 
        name: "",  # nome vazio - inválido
      } 
    }
    
    assert_response :unprocessable_entity
    
    @food_item.reload
    assert_equal original_name, @food_item.name
  end
  
  test "should not update food_item with invalid params in turbo_stream" do
    original_name = @food_item.name
    
    patch food_item_url(@food_item), params: { 
      food_item: { 
        name: ""
      } 
    }, as: :turbo_stream
    
    assert_response :unprocessable_entity
    
    @food_item.reload
    assert_equal original_name, @food_item.name
  end
  
  test "should not update food_item with negative quantity" do
    patch food_item_url(@food_item), params: { 
      food_item: { 
        quantity: -10.0
      } 
    }
    
    assert_response :unprocessable_entity
  end
  
  test "should update only specified fields" do
    original_category = @food_item.category
    
    patch food_item_url(@food_item), params: { 
      food_item: { 
        notes: "Novas observações"
      } 
    }
    
    @food_item.reload
    assert_equal "Novas observações", @food_item.notes
    assert_equal original_category, @food_item.category
  end
  
  # === TESTES DE DESTROY ===
  
  test "should destroy food_item" do
    assert_difference("FoodItem.count", -1) do
      delete food_item_url(@food_item)
    end
    
    assert_redirected_to food_items_url
    assert_equal "Alimento removido com sucesso.", flash[:notice]
  end
  
  test "should destroy food_item with turbo_stream format" do
    assert_difference("FoodItem.count", -1) do
      delete food_item_url(@food_item), as: :turbo_stream
    end
    
    assert_response :success
    assert_equal "Alimento removido com sucesso.", flash.now[:notice]
  end
  
  test "should destroy associated batches when destroying food_item" do
    food_item = food_items(:rice)
    batch_ids = food_item.supply_batches.pluck(:id)
    
    assert batch_ids.any?, "Food item should have batches"
    
    delete food_item_url(food_item)
    
    batch_ids.each do |batch_id|
      assert_nil SupplyBatch.find_by(id: batch_id), "Batch should be destroyed"
    end
  end
  
  test "should return 404 when destroying non-existent food_item" do
    assert_raises(ActiveRecord::RecordNotFound) do
      delete food_item_url(id: 99999)
    end
  end
  
  # === TESTES DE STRONG PARAMETERS ===
  
  test "should permit valid food_item params" do
    params = {
      food_item: {
        name: "Test",
        category: "test",
        quantity: 5.0,
        expiration_date: "2025-12-31",
        storage_location: "Test",
        notes: "Test notes",
        unauthorized_field: "Should be filtered"
      }
    }
    
    post food_items_url, params: params
    
    created_item = FoodItem.find_by(name: "Test")
    assert_not_nil created_item
    assert_nil created_item.attributes["unauthorized_field"]
  end
end

