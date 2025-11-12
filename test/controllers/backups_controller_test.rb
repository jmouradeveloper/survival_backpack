require "test_helper"

class BackupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @food_item = FoodItem.create!(
      name: "Arroz",
      category: "grains",
      quantity: 10.0,
      expiration_date: Date.today + 30.days
    )
  end
  
  test "should get index" do
    get backups_url
    assert_response :success
    assert_select "h1", text: /Backup/i
  end
  
  test "should get new import page" do
    get new_backup_url
    assert_response :success
    assert_select "form[action=?]", backups_url
  end
  
  test "should export to json" do
    get export_backups_url(format: :json)
    assert_response :success
    assert_equal "application/json", response.media_type
    
    data = JSON.parse(response.body)
    assert data.key?("version")
    assert data.key?("food_items")
    assert data.key?("supply_batches")
    assert data.key?("supply_rotations")
  end
  
  test "should download json file" do
    get export_backups_url(format: :json, download: true)
    assert_response :success
    assert_match /attachment/, response.headers['Content-Disposition']
    assert_match /backup.*\.json/, response.headers['Content-Disposition']
  end
  
  test "should export to csv" do
    get export_backups_url(format: :csv)
    assert_response :success
  end
  
  test "should import from json with merge strategy" do
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
    }.to_json
    
    initial_count = FoodItem.count
    
    post backups_url, params: {
      backup: {
        file_content: json_data,
        file_type: "json",
        strategy: "merge"
      }
    }
    
    assert_redirected_to backups_url
    follow_redirect!
    
    assert_select "div.alert-success"
    assert_equal initial_count + 1, FoodItem.count
  end
  
  test "should import from json with replace strategy" do
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
    }.to_json
    
    post backups_url, params: {
      backup: {
        file_content: json_data,
        file_type: "json",
        strategy: "replace"
      }
    }
    
    assert_redirected_to backups_url
    follow_redirect!
    
    assert_select "div.alert-success"
    assert_equal 1, FoodItem.count
    assert FoodItem.find_by(name: "Feijão").present?
  end
  
  test "should handle import errors" do
    invalid_json = "invalid json"
    
    post backups_url, params: {
      backup: {
        file_content: invalid_json,
        file_type: "json",
        strategy: "merge"
      }
    }
    
    assert_response :unprocessable_entity
    assert_select "div.alert-danger"
  end
  
  test "should handle file upload" do
    file = fixture_file_upload('files/backup.json', 'application/json')
    
    post backups_url, params: {
      backup: {
        file: file,
        strategy: "merge"
      }
    }
    
    # Deve processar o arquivo
    assert_response :redirect
  end
  
  test "should validate required params on import" do
    post backups_url, params: {
      backup: {}
    }
    
    assert_response :unprocessable_entity
  end
  
  test "should show import statistics on success" do
    json_data = {
      version: "1.0",
      exported_at: Time.current.iso8601,
      food_items: [
        { id: 999, name: "Item 1", category: "test", quantity: "1.0" },
        { id: 998, name: "Item 2", category: "test", quantity: "2.0" }
      ],
      supply_batches: [],
      supply_rotations: []
    }.to_json
    
    post backups_url, params: {
      backup: {
        file_content: json_data,
        file_type: "json",
        strategy: "merge"
      }
    }
    
    follow_redirect!
    assert_match /2.*criado/i, response.body
  end
end

