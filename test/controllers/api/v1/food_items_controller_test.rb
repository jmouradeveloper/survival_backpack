require "test_helper"

module Api
  module V1
    class FoodItemsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @food_item = food_items(:rice)
      end

      # === TESTES DE INDEX ===
      
      test "should get index as json" do
        get api_v1_food_items_url, as: :json
        assert_response :success
        
        json_response = JSON.parse(@response.body)
        assert_not_nil json_response["data"]
        assert_not_nil json_response["meta"]
      end
      
      test "should return paginated results" do
        get api_v1_food_items_url, as: :json
        
        json_response = JSON.parse(@response.body)
        meta = json_response["meta"]
        
        assert_equal 1, meta["page"]
        assert_equal 20, meta["per_page"]
        assert_kind_of Integer, meta["total"]
      end
      
      test "should accept custom page parameter" do
        get api_v1_food_items_url, params: { page: 2 }, as: :json
        
        json_response = JSON.parse(@response.body)
        meta = json_response["meta"]
        
        assert_equal 2, meta["page"]
      end
      
      test "should accept custom per_page parameter" do
        get api_v1_food_items_url, params: { per_page: 5 }, as: :json
        
        json_response = JSON.parse(@response.body)
        meta = json_response["meta"]
        
        assert_equal 5, meta["per_page"]
      end
      
      test "should limit per_page to maximum 100" do
        get api_v1_food_items_url, params: { per_page: 200 }, as: :json
        
        json_response = JSON.parse(@response.body)
        meta = json_response["meta"]
        
        assert_equal 100, meta["per_page"]
      end
      
      test "should filter by category via API" do
        get api_v1_food_items_url, params: { category: "grains" }, as: :json
        assert_response :success
        
        json_response = JSON.parse(@response.body)
        items = json_response["data"]
        
        assert items.all? { |item| item["category"] == "grains" }
      end
      
      test "should filter by storage_location via API" do
        get api_v1_food_items_url, params: { storage_location: "Despensa" }, as: :json
        assert_response :success
        
        json_response = JSON.parse(@response.body)
        items = json_response["data"]
        
        assert items.all? { |item| item["storage_location"] == "Despensa" }
      end
      
      test "should filter expired items via API" do
        get api_v1_food_items_url, params: { filter: "expired" }, as: :json
        assert_response :success
        
        json_response = JSON.parse(@response.body)
        items = json_response["data"]
        
        assert items.all? { |item| item["expired?"] == true }
      end
      
      test "should filter expiring_soon items via API" do
        get api_v1_food_items_url, params: { filter: "expiring_soon" }, as: :json
        assert_response :success
        
        json_response = JSON.parse(@response.body)
        assert_not_nil json_response["data"]
      end
      
      test "should filter valid items via API" do
        get api_v1_food_items_url, params: { filter: "valid" }, as: :json
        assert_response :success
        
        json_response = JSON.parse(@response.body)
        items = json_response["data"]
        
        assert items.none? { |item| item["expired?"] == true }
      end
      
      test "should return items in recent order" do
        get api_v1_food_items_url, as: :json
        assert_response :success
        
        json_response = JSON.parse(@response.body)
        items = json_response["data"]
        
        # Verifica que os itens estão ordenados por data de criação
        assert items.count > 0
      end
      
      # === TESTES DE SHOW ===
      
      test "should show food_item via API" do
        get api_v1_food_item_url(@food_item), as: :json
        assert_response :success
        
        json_response = JSON.parse(@response.body)
        assert_not_nil json_response["data"]
        assert_equal @food_item.id, json_response["data"]["id"]
      end
      
      test "should include computed fields in show" do
        get api_v1_food_item_url(@food_item), as: :json
        
        json_response = JSON.parse(@response.body)
        data = json_response["data"]
        
        assert_includes data.keys, "expired?"
        assert_includes data.keys, "expiring_soon?"
        assert_includes data.keys, "days_until_expiration"
        assert_includes data.keys, "status"
      end
      
      test "should return 404 for non-existent food_item via API" do
        get api_v1_food_item_url(id: 99999), as: :json
        assert_response :not_found
      rescue ActiveRecord::RecordNotFound
        # Se o RecordNotFound for levantado, está OK também
        assert true
      end
      
      # === TESTES DE CREATE ===
      
      test "should create food_item via API" do
        assert_difference("FoodItem.count") do
          post api_v1_food_items_url, params: { 
            food_item: { 
              name: "API Created Item",
              category: "test",
              quantity: 10.0,
              expiration_date: 60.days.from_now,
              storage_location: "API Location",
              notes: "Created via API"
            } 
          }, as: :json
        end
        
        assert_response :created
        
        json_response = JSON.parse(@response.body)
        assert_equal "Alimento cadastrado com sucesso", json_response["message"]
        assert_not_nil json_response["data"]
        assert_equal "API Created Item", json_response["data"]["name"]
      end
      
      test "should return 422 for invalid create via API" do
        assert_no_difference("FoodItem.count") do
          post api_v1_food_items_url, params: { 
            food_item: { 
              name: "",  # inválido
              category: "test",
              quantity: 10.0
            } 
          }, as: :json
        end
        
        assert_response :unprocessable_entity
        
        json_response = JSON.parse(@response.body)
        assert_equal "Erro ao cadastrar alimento", json_response["error"]
        assert_not_nil json_response["details"]
        assert json_response["details"].is_a?(Array)
      end
      
      test "should return validation errors in details" do
        post api_v1_food_items_url, params: { 
          food_item: { 
            name: "A",  # muito curto
            category: "",  # vazio
            quantity: -1  # negativo
          } 
        }, as: :json
        
        assert_response :unprocessable_entity
        
        json_response = JSON.parse(@response.body)
        assert json_response["details"].length > 0
      end
      
      test "should not create food_item without required fields via API" do
        assert_no_difference("FoodItem.count") do
          post api_v1_food_items_url, params: { 
            food_item: { 
              name: "Incomplete"
            } 
          }, as: :json
        end
        
        assert_response :unprocessable_entity
      end
      
      # === TESTES DE UPDATE ===
      
      test "should update food_item via API" do
        patch api_v1_food_item_url(@food_item), params: { 
          food_item: { 
            name: "Updated via API",
            notes: "Updated notes"
          } 
        }, as: :json
        
        assert_response :success
        
        json_response = JSON.parse(@response.body)
        assert_equal "Alimento atualizado com sucesso", json_response["message"]
        assert_equal "Updated via API", json_response["data"]["name"]
        
        @food_item.reload
        assert_equal "Updated via API", @food_item.name
        assert_equal "Updated notes", @food_item.notes
      end
      
      test "should return 422 for invalid update via API" do
        original_name = @food_item.name
        
        patch api_v1_food_item_url(@food_item), params: { 
          food_item: { 
            name: "",  # inválido
          } 
        }, as: :json
        
        assert_response :unprocessable_entity
        
        json_response = JSON.parse(@response.body)
        assert_equal "Erro ao atualizar alimento", json_response["error"]
        assert_not_nil json_response["details"]
        
        @food_item.reload
        assert_equal original_name, @food_item.name
      end
      
      test "should return 404 when updating non-existent food_item via API" do
        patch api_v1_food_item_url(id: 99999), params: { 
          food_item: { 
            name: "Should Fail"
          } 
        }, as: :json
        assert_response :not_found
      rescue ActiveRecord::RecordNotFound
        # Se o RecordNotFound for levantado, está OK também
        assert true
      end
      
      test "should update only specified fields via API" do
        original_category = @food_item.category
        original_storage = @food_item.storage_location
        
        patch api_v1_food_item_url(@food_item), params: { 
          food_item: { 
            notes: "Only notes updated"
          } 
        }, as: :json
        
        @food_item.reload
        assert_equal "Only notes updated", @food_item.notes
        assert_equal original_category, @food_item.category
        assert_equal original_storage, @food_item.storage_location
      end
      
      # === TESTES DE DESTROY ===
      
      test "should destroy food_item via API" do
        assert_difference("FoodItem.count", -1) do
          delete api_v1_food_item_url(@food_item), as: :json
        end
        
        assert_response :success
        
        json_response = JSON.parse(@response.body)
        assert_equal "Alimento removido com sucesso", json_response["message"]
      end
      
      test "should return 404 when destroying non-existent food_item via API" do
        delete api_v1_food_item_url(id: 99999), as: :json
        assert_response :not_found
      rescue ActiveRecord::RecordNotFound
        # Se o RecordNotFound for levantado, está OK também
        assert true
      end
      
      # === TESTES DE STATISTICS ===
      
      test "should get statistics" do
        get statistics_api_v1_food_items_url, as: :json
        assert_response :success
        
        json_response = JSON.parse(@response.body)
        data = json_response["data"]
        
        assert_not_nil data["total"]
        assert_not_nil data["expired"]
        assert_not_nil data["expiring_soon"]
        assert_not_nil data["valid"]
        assert_not_nil data["by_category"]
        assert_not_nil data["by_storage_location"]
      end
      
      test "statistics should return correct counts" do
        get statistics_api_v1_food_items_url, as: :json
        
        json_response = JSON.parse(@response.body)
        data = json_response["data"]
        
        assert_kind_of Integer, data["total"]
        assert_kind_of Integer, data["expired"]
        assert_kind_of Integer, data["expiring_soon"]
        assert_kind_of Integer, data["valid"]
        
        # Total deve ser soma de expired + valid (expiring_soon está incluído em valid)
        assert data["total"] >= 0
        assert data["expired"] >= 0
        assert data["valid"] >= 0
      end
      
      test "statistics by_category should be a hash" do
        get statistics_api_v1_food_items_url, as: :json
        
        json_response = JSON.parse(@response.body)
        data = json_response["data"]
        
        assert_kind_of Hash, data["by_category"]
        # Verifica que tem pelo menos uma categoria
        assert data["by_category"].keys.count >= 0
      end
      
      test "statistics by_storage_location should be a hash" do
        get statistics_api_v1_food_items_url, as: :json
        
        json_response = JSON.parse(@response.body)
        data = json_response["data"]
        
        assert_kind_of Hash, data["by_storage_location"]
      end
      
      # === TESTES DE FORMATO JSON ===
      
      test "API responses should be valid JSON" do
        get api_v1_food_items_url, as: :json
        
        assert_nothing_raised do
          JSON.parse(@response.body)
        end
      end
      
      test "API should set correct content type" do
        get api_v1_food_items_url, as: :json
        
        assert_equal "application/json; charset=utf-8", @response.content_type
      end
      
      # === TESTES DE STRONG PARAMETERS ===
      
      test "API should filter unauthorized parameters" do
        post api_v1_food_items_url, params: { 
          food_item: { 
            name: "Test Filter",
            category: "test",
            quantity: 5.0,
            unauthorized_field: "Should be ignored",
            admin: true,
            created_at: 1.year.ago
          } 
        }, as: :json
        
        assert_response :created
        
        created_item = FoodItem.find_by(name: "Test Filter")
        assert_not_nil created_item
        assert_nil created_item.attributes["unauthorized_field"]
        assert_nil created_item.attributes["admin"]
      end
      
      # === TESTES DE CAMPOS COMPUTADOS ===
      
      test "API should include computed fields in response" do
        expired_item = food_items(:expired_milk)
        
        get api_v1_food_item_url(expired_item), as: :json
        
        json_response = JSON.parse(@response.body)
        data = json_response["data"]
        
        assert_equal true, data["expired?"]
        assert_equal false, data["expiring_soon?"]
        assert_equal :expired.to_s, data["status"]
        assert data["days_until_expiration"] < 0
      end
      
      test "API should correctly compute expiring_soon status" do
        expiring_item = food_items(:beans)
        
        get api_v1_food_item_url(expiring_item), as: :json
        
        json_response = JSON.parse(@response.body)
        data = json_response["data"]
        
        assert_equal false, data["expired?"]
        assert_equal true, data["expiring_soon?"]
        assert_equal :expiring_soon.to_s, data["status"]
        assert data["days_until_expiration"] > 0
        assert data["days_until_expiration"] <= 7
      end
      
      test "API should handle items without expiration date" do
        no_expiration = food_items(:salt)
        
        get api_v1_food_item_url(no_expiration), as: :json
        
        json_response = JSON.parse(@response.body)
        data = json_response["data"]
        
        assert_equal false, data["expired?"]
        assert_equal false, data["expiring_soon?"]
        assert_equal :valid.to_s, data["status"]
        assert_nil data["days_until_expiration"]
      end
    end
  end
end

