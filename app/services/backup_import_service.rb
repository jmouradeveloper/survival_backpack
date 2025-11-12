require 'csv'
require 'json'

class BackupImportService
  attr_reader :errors, :warnings
  
  def initialize
    @errors = []
    @warnings = []
  end
  
  def import_from_json(json_data, strategy: :merge)
    @errors = []
    @warnings = []
    
    begin
      data = JSON.parse(json_data, symbolize_names: true)
    rescue JSON::ParserError => e
      @errors << "Formato JSON inválido: #{e.message}"
      return result_hash(false)
    end
    
    perform_import(data, strategy)
  end
  
  def import_from_csv(csv_data, strategy: :merge)
    @errors = []
    @warnings = []
    
    begin
      data = parse_csv_data(csv_data)
      perform_import(data, strategy)
    rescue => e
      @errors << "Erro ao processar CSV: #{e.message}"
      return result_hash(false)
    end
  end
  
  private
  
  def perform_import(data, strategy)
    food_items_created = 0
    food_items_updated = 0
    supply_batches_created = 0
    supply_rotations_created = 0
    
    ActiveRecord::Base.transaction do
      # Se estratégia é replace, limpa dados existentes
      if strategy == :replace
        clear_all_data
      end
      
      # Mapeia IDs antigos para novos
      id_mapping = {
        food_items: {},
        supply_batches: {}
      }
      
      # Importa food_items
      Array(data[:food_items]).each do |item_data|
        old_id = item_data[:id]
        
        if strategy == :merge
          result = import_food_item_merge(item_data)
          if result[:created]
            food_items_created += 1
            id_mapping[:food_items][old_id] = result[:record].id
          else
            food_items_updated += 1
            id_mapping[:food_items][old_id] = result[:record].id
          end
        else
          result = import_food_item_replace(item_data)
          food_items_created += 1
          id_mapping[:food_items][old_id] = result[:record].id
        end
      end
      
      # Importa supply_batches
      Array(data[:supply_batches]).each do |batch_data|
        old_id = batch_data[:id]
        old_food_item_id = batch_data[:food_item_id]
        new_food_item_id = id_mapping[:food_items][old_food_item_id]
        
        if new_food_item_id
          batch_data[:food_item_id] = new_food_item_id
          result = import_supply_batch(batch_data)
          supply_batches_created += 1
          id_mapping[:supply_batches][old_id] = result[:record].id
        else
          @warnings << "Supply batch #{old_id} ignorado: food_item não encontrado"
        end
      end
      
      # Importa supply_rotations
      Array(data[:supply_rotations]).each do |rotation_data|
        old_food_item_id = rotation_data[:food_item_id]
        old_batch_id = rotation_data[:supply_batch_id]
        
        new_food_item_id = id_mapping[:food_items][old_food_item_id]
        new_batch_id = id_mapping[:supply_batches][old_batch_id]
        
        if new_food_item_id && new_batch_id
          rotation_data[:food_item_id] = new_food_item_id
          rotation_data[:supply_batch_id] = new_batch_id
          import_supply_rotation(rotation_data)
          supply_rotations_created += 1
        else
          @warnings << "Supply rotation ignorado: referências não encontradas"
        end
      end
      
      if @errors.any?
        raise ActiveRecord::Rollback
      end
    end
    
    result_hash(
      @errors.empty?,
      food_items_created: food_items_created,
      food_items_updated: food_items_updated,
      supply_batches_created: supply_batches_created,
      supply_rotations_created: supply_rotations_created
    )
  rescue => e
    @errors << "Erro durante importação: #{e.message}"
    result_hash(false)
  end
  
  def import_food_item_merge(item_data)
    # Tenta encontrar item existente pelo nome
    existing = FoodItem.find_by(name: item_data[:name])
    
    attributes = extract_food_item_attributes(item_data)
    
    if existing
      existing.update!(attributes)
      { created: false, record: existing }
    else
      record = FoodItem.create!(attributes)
      { created: true, record: record }
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Food item inválido: #{e.message}"
    raise
  end
  
  def import_food_item_replace(item_data)
    attributes = extract_food_item_attributes(item_data)
    record = FoodItem.create!(attributes)
    { created: true, record: record }
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Food item inválido: #{e.message}"
    raise
  end
  
  def import_supply_batch(batch_data)
    attributes = {
      food_item_id: batch_data[:food_item_id],
      initial_quantity: batch_data[:initial_quantity].to_f,
      current_quantity: batch_data[:current_quantity].to_f,
      entry_date: parse_date(batch_data[:entry_date]),
      expiration_date: parse_date(batch_data[:expiration_date]),
      batch_code: batch_data[:batch_code],
      supplier: batch_data[:supplier],
      unit_cost: batch_data[:unit_cost]&.to_f,
      notes: batch_data[:notes],
      status: batch_data[:status] || 'active'
    }
    
    record = SupplyBatch.create!(attributes)
    { created: true, record: record }
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Supply batch inválido: #{e.message}"
    raise
  end
  
  def import_supply_rotation(rotation_data)
    attributes = {
      supply_batch_id: rotation_data[:supply_batch_id],
      food_item_id: rotation_data[:food_item_id],
      quantity: rotation_data[:quantity].to_f,
      rotation_date: parse_date(rotation_data[:rotation_date]),
      rotation_type: rotation_data[:rotation_type],
      reason: rotation_data[:reason],
      notes: rotation_data[:notes]
    }
    
    SupplyRotation.create!(attributes)
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Supply rotation inválido: #{e.message}"
    raise
  end
  
  def extract_food_item_attributes(item_data)
    {
      name: item_data[:name],
      category: item_data[:category],
      quantity: item_data[:quantity].to_f,
      expiration_date: parse_date(item_data[:expiration_date]),
      storage_location: item_data[:storage_location],
      notes: item_data[:notes]
    }
  end
  
  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string.to_s)
  rescue ArgumentError
    nil
  end
  
  def parse_csv_data(csv_data)
    data = {
      food_items: [],
      supply_batches: [],
      supply_rotations: []
    }
    
    # Parse food_items CSV
    if csv_data[:food_items].present?
      CSV.parse(csv_data[:food_items], headers: true) do |row|
        data[:food_items] << row.to_h.symbolize_keys
      end
    end
    
    # Parse supply_batches CSV
    if csv_data[:supply_batches].present?
      CSV.parse(csv_data[:supply_batches], headers: true) do |row|
        data[:supply_batches] << row.to_h.symbolize_keys
      end
    end
    
    # Parse supply_rotations CSV
    if csv_data[:supply_rotations].present?
      CSV.parse(csv_data[:supply_rotations], headers: true) do |row|
        data[:supply_rotations] << row.to_h.symbolize_keys
      end
    end
    
    data
  end
  
  def clear_all_data
    SupplyRotation.destroy_all
    SupplyBatch.destroy_all
    FoodItem.destroy_all
  end
  
  def result_hash(success, extra = {})
    {
      success: success,
      food_items_created: extra[:food_items_created] || 0,
      food_items_updated: extra[:food_items_updated] || 0,
      supply_batches_created: extra[:supply_batches_created] || 0,
      supply_rotations_created: extra[:supply_rotations_created] || 0,
      errors: @errors,
      warnings: @warnings
    }
  end
end

