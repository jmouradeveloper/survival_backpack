require "test_helper"

class Api::V1::BackupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
    @token = @user.api_tokens.create!(
      name: "Test Token",
      expires_at: 1.year.from_now
    )
    @auth_headers = { "Authorization" => "Bearer #{@token.raw_token}" }
    
    @food_item = FoodItem.create!(
      user: @user,
      name: "Arroz",
      category: "grains",
      quantity: 10.0,
      expiration_date: Date.today + 30.days
    )
  end
  
  test "should export to json via api" do
    get api_v1_backups_export_url(format: :json), headers: @auth_headers
    assert_response :success
    
    data = JSON.parse(response.body)
    assert data.key?("version")
    assert data.key?("food_items")
    # 8 fixtures + 1 criado no setup = 9 total
    assert_equal @user.food_items.count, data["food_items"].length, "Should export all current user's food items"
  end
  
  test "should import from json via api with merge strategy" do
    json_data = {
      version: "1.0",
      exported_at: Time.current.iso8601,
      food_items: [
        {
          id: 999,
          name: "Feijão",
          category: "legumes",
          quantity: "5.0",
          expiration_date: (Date.today + 60.days).iso8601
        }
      ],
      supply_batches: [],
      supply_rotations: []
    }
    
    initial_count = FoodItem.count
    
    post api_v1_backups_import_url, 
         params: { data: json_data.to_json, strategy: "merge" },
         headers: @auth_headers,
         as: :json
    
    assert_response :success
    
    result = JSON.parse(response.body)
    assert result["success"]
    assert_equal initial_count + 1, FoodItem.count
  end
  
  test "should import from json via api with replace strategy" do
    json_data = {
      version: "1.0",
      exported_at: Time.current.iso8601,
      food_items: [
        {
          id: 999,
          name: "Feijão",
          category: "legumes",
          quantity: "5.0",
          expiration_date: (Date.today + 60.days).iso8601
        }
      ],
      supply_batches: [],
      supply_rotations: []
    }
    
    post api_v1_backups_import_url, 
         params: { data: json_data.to_json, strategy: "replace" },
         headers: @auth_headers,
         as: :json
    
    assert_response :success
    
    result = JSON.parse(response.body)
    assert result["success"]
    assert_equal 1, FoodItem.count
  end
  
  test "should return errors on invalid import" do
    invalid_json = "invalid json"
    
    post api_v1_backups_import_url, 
         params: { data: invalid_json, strategy: "merge" },
         headers: @auth_headers,
         as: :json
    
    assert_response :unprocessable_entity
    
    result = JSON.parse(response.body)
    assert_not result["success"]
    assert result["errors"].present?
  end
  
  test "should return statistics on successful import" do
    json_data = {
      version: "1.0",
      exported_at: Time.current.iso8601,
      food_items: [
        { id: 999, name: "Item 1", category: "test", quantity: "1.0" },
        { id: 998, name: "Item 2", category: "test", quantity: "2.0" }
      ],
      supply_batches: [],
      supply_rotations: []
    }
    
    post api_v1_backups_import_url, 
         params: { data: json_data.to_json, strategy: "merge" },
         headers: @auth_headers,
         as: :json
    
    assert_response :success
    
    result = JSON.parse(response.body)
    assert result["success"]
    assert_equal 2, result["food_items_created"]
  end
  
  test "should validate required params" do
    post api_v1_backups_import_url, params: {}, headers: @auth_headers, as: :json
    
    assert_response :unprocessable_entity
  end
  
  test "should handle csv export via api" do
    get api_v1_backups_export_url(format: :json, export_format: "csv"), headers: @auth_headers
    assert_response :success
    
    data = JSON.parse(response.body)
    assert data.key?("food_items")
    assert data.key?("supply_batches")
    assert data.key?("supply_rotations")
  end
end

