class BackupsController < ApplicationController
  include Authorization
  
  # GET /backups
  def index
    # Interface principal de backup
  end
  
  # GET /backups/new
  def new
    # Formulário de importação
  end
  
  # GET /backups/export
  def export
    service = BackupExportService.new(current_user)
    
    respond_to do |format|
      format.json do
        json_data = service.export_to_json
        
        if params[:download]
          filename = "backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json"
          send_data json_data, 
                    filename: filename,
                    type: 'application/json',
                    disposition: 'attachment'
        else
          render json: json_data
        end
      end
      
      format.csv do
        csv_data = service.export_to_csv
        filename = "backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.zip"
        
        # Cria arquivo ZIP com os 3 CSVs
        zip_data = create_zip_from_csv(csv_data)
        
        send_data zip_data,
                  filename: filename,
                  type: 'application/zip',
                  disposition: 'attachment'
      end
    end
  end
  
  # POST /backups
  def create
    unless params[:backup].present?
      flash.now[:alert] = "Parâmetros inválidos"
      render :new, status: :unprocessable_entity
      return
    end
    
    strategy = params[:backup][:strategy]&.to_sym || :merge
    
    # Verifica se foi upload de arquivo ou conteúdo direto
    if params[:backup][:file].present?
      file = params[:backup][:file]
      file_content = file.read
      file_type = detect_file_type(file)
    elsif params[:backup][:file_content].present?
      file_content = params[:backup][:file_content]
      file_type = params[:backup][:file_type]
    else
      flash.now[:alert] = "Nenhum arquivo foi enviado"
      render :new, status: :unprocessable_entity
      return
    end
    
    service = BackupImportService.new(current_user)
    
    result = if file_type == "json"
      service.import_from_json(file_content, strategy: strategy)
    elsif file_type == "csv"
      csv_data = parse_csv_upload(file_content)
      service.import_from_csv(csv_data, strategy: strategy)
    else
      { success: false, errors: ["Tipo de arquivo não suportado"] }
    end
    
    if result[:success]
      message = build_success_message(result)
      flash[:success] = message
      redirect_to backups_url
    else
      flash.now[:alert] = "Erro ao importar: #{result[:errors].join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def detect_file_type(file)
    content_type = file.content_type
    filename = file.original_filename
    
    if content_type.include?("json") || filename.end_with?(".json")
      "json"
    elsif content_type.include?("csv") || filename.end_with?(".csv")
      "csv"
    elsif filename.end_with?(".zip")
      "csv"  # ZIP contém CSVs
    else
      "unknown"
    end
  end
  
  def parse_csv_upload(content)
    # Se for ZIP, extrai os CSVs
    if content.start_with?("PK")  # Magic number para ZIP
      require 'zip'
      csv_data = {}
      
      Zip::File.open_buffer(content) do |zip|
        zip.each do |entry|
          if entry.name.include?("food_items")
            csv_data[:food_items] = entry.get_input_stream.read
          elsif entry.name.include?("supply_batches")
            csv_data[:supply_batches] = entry.get_input_stream.read
          elsif entry.name.include?("supply_rotations")
            csv_data[:supply_rotations] = entry.get_input_stream.read
          end
        end
      end
      
      csv_data
    else
      # CSV único - assume que é food_items
      {
        food_items: content,
        supply_batches: "",
        supply_rotations: ""
      }
    end
  end
  
  def create_zip_from_csv(csv_data)
    require 'zip'
    
    buffer = Zip::OutputStream.write_buffer do |zip|
      zip.put_next_entry("food_items.csv")
      zip.write csv_data[:food_items]
      
      zip.put_next_entry("supply_batches.csv")
      zip.write csv_data[:supply_batches]
      
      zip.put_next_entry("supply_rotations.csv")
      zip.write csv_data[:supply_rotations]
    end
    
    buffer.string
  end
  
  def build_success_message(result)
    parts = []
    parts << "#{result[:food_items_created]} alimento(s) criado(s)" if result[:food_items_created] > 0
    parts << "#{result[:food_items_updated]} alimento(s) atualizado(s)" if result[:food_items_updated] > 0
    parts << "#{result[:supply_batches_created]} lote(s) criado(s)" if result[:supply_batches_created] > 0
    parts << "#{result[:supply_rotations_created]} rotação(ões) criada(s)" if result[:supply_rotations_created] > 0
    
    message = "Backup importado com sucesso! "
    message += parts.join(", ") if parts.any?
    
    if result[:warnings].any?
      message += " Avisos: #{result[:warnings].join(', ')}"
    end
    
    message
  end
end

