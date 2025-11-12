module Api
  module V1
    class SupplyRotationsController < BaseController
      before_action :set_supply_rotation, only: [:show, :destroy]
      
      # GET /api/v1/supply_rotations
      def index
        @supply_rotations = current_user.supply_rotations.includes(:food_item, :supply_batch)
        
        # Filtros
        @supply_rotations = @supply_rotations.by_food_item(params[:food_item_id]) if params[:food_item_id].present?
        @supply_rotations = @supply_rotations.by_type(params[:rotation_type]) if params[:rotation_type].present?
        
        if params[:start_date].present? && params[:end_date].present?
          @supply_rotations = @supply_rotations.by_date_range(
            Date.parse(params[:start_date]),
            Date.parse(params[:end_date])
          )
        end
        
        # Paginação
        page = params[:page] || 1
        per_page = [params[:per_page].to_i, 100].min
        per_page = 20 if per_page <= 0
        
        @supply_rotations = @supply_rotations.recent.page(page).per(per_page)
        
        render json: {
          supply_rotations: @supply_rotations.as_json,
          meta: {
            current_page: @supply_rotations.current_page,
            total_pages: @supply_rotations.total_pages,
            total_count: @supply_rotations.total_count
          }
        }
      end
      
      # GET /api/v1/supply_rotations/:id
      def show
        render json: @supply_rotation.as_json
      end
      
      # POST /api/v1/supply_rotations
      def create
        supply_batch = current_user.supply_batches.find(rotation_params[:supply_batch_id])
        quantity = rotation_params[:quantity].to_f
        
        begin
          rotation = supply_batch.consume!(
            quantity,
            rotation_type: rotation_params[:rotation_type],
            reason: rotation_params[:reason],
            notes: rotation_params[:notes]
          )
          
          render json: rotation, status: :created
        rescue StandardError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/supply_rotations/:id
      def destroy
        @supply_rotation.destroy
        head :no_content
      end
      
      # POST /api/v1/supply_rotations/consume_fifo
      def consume_fifo
        food_item = current_user.food_items.find(params[:food_item_id])
        quantity = params[:quantity].to_f
        rotation_type = params[:rotation_type] || 'consumption'
        reason = params[:reason]
        notes = params[:notes]
        
        begin
          rotations = food_item.consume_fifo!(
            quantity,
            rotation_type: rotation_type,
            reason: reason,
            notes: notes
          )
          
          render json: {
            message: "Successfully consumed #{quantity} using FIFO strategy",
            rotations: rotations.map(&:as_json),
            food_item: food_item.reload.as_json(
              methods: [:total_batch_quantity],
              include: { supply_batches: { only: [:id, :current_quantity, :status] } }
            )
          }, status: :ok
        rescue StandardError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      # GET /api/v1/supply_rotations/statistics
      def statistics
        start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
        end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil
        
        stats = SupplyRotation.statistics(start_date, end_date)
        
        # Se tiver food_item_id, adiciona estatísticas específicas
        if params[:food_item_id].present?
          food_item = current_user.food_items.find(params[:food_item_id])
          rotations = current_user.supply_rotations.by_food_item(food_item.id)
          rotations = rotations.by_date_range(start_date, end_date) if start_date && end_date
          
          stats[:food_item] = {
            id: food_item.id,
            name: food_item.name,
            total_consumed: rotations.consumption.sum(:quantity),
            total_wasted: rotations.waste.sum(:quantity),
            total_donated: rotations.donation.sum(:quantity),
            total_transferred: rotations.transfer.sum(:quantity)
          }
        end
        
        render json: stats
      end
      
      private
      
      def set_supply_rotation
        @supply_rotation = current_user.supply_rotations.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Supply rotation not found' }, status: :not_found
      end
      
      def rotation_params
        params.require(:supply_rotation).permit(
          :supply_batch_id,
          :food_item_id,
          :quantity,
          :rotation_date,
          :rotation_type,
          :reason,
          :notes
        )
      end
    end
  end
end

