module Api
  module V1
    class BackupsController < BaseController
      # GET /api/v1/backups/export
      def export
        service = BackupExportService.new(current_user)
        
        if params[:export_format] == "csv"
          csv_data = service.export_to_csv
          render json: csv_data
        else
          json_data = service.export_to_json
          render json: JSON.parse(json_data)
        end
      end
      
      # POST /api/v1/backups/import
      def import
        unless params[:data].present?
          render json: { 
            success: false, 
            errors: ["Dados não fornecidos"] 
          }, status: :unprocessable_entity
          return
        end
        
        strategy = params[:strategy]&.to_sym || :merge
        service = BackupImportService.new(current_user)
        
        result = service.import_from_json(params[:data], strategy: strategy)
        
        if result[:success]
          render json: result, status: :ok
        else
          render json: result, status: :unprocessable_entity
        end
      end
    end
  end
end

