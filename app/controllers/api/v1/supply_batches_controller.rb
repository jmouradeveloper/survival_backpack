module Api
  module V1
    class SupplyBatchesController < BaseController
      before_action :set_supply_batch, only: [:show, :update, :destroy, :consume]
      
      # GET /api/v1/supply_batches
      def index
        @supply_batches = current_user.supply_batches.includes(:food_item)
        
        # Filtros
        @supply_batches = @supply_batches.by_food_item(params[:food_item_id]) if params[:food_item_id].present?
        @supply_batches = @supply_batches.where(status: params[:status]) if params[:status].present?
        
        # Ordenação
        @supply_batches = if params[:sort] == 'recent'
          @supply_batches.recent
        else
          @supply_batches.by_fifo_order
        end
        
        # Paginação
        page = params[:page] || 1
        per_page = [params[:per_page].to_i, 100].min
        per_page = 20 if per_page <= 0
        
        @supply_batches = @supply_batches.page(page).per(per_page)
        
        render json: {
          supply_batches: @supply_batches.as_json,
          meta: {
            current_page: @supply_batches.current_page,
            total_pages: @supply_batches.total_pages,
            total_count: @supply_batches.total_count
          }
        }
      end
      
      # GET /api/v1/supply_batches/:id
      def show
        render json: @supply_batch.as_json(
          include: {
            supply_rotations: { 
              only: [:id, :quantity, :rotation_date, :rotation_type, :reason] 
            }
          }
        )
      end
      
      # POST /api/v1/supply_batches
      def create
        @supply_batch = current_user.supply_batches.new(supply_batch_params)
        
        if @supply_batch.save
          render json: @supply_batch, status: :created
        else
          render json: { errors: @supply_batch.errors }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/supply_batches/:id
      def update
        if @supply_batch.update(supply_batch_params)
          render json: @supply_batch
        else
          render json: { errors: @supply_batch.errors }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/supply_batches/:id
      def destroy
        @supply_batch.destroy
        head :no_content
      end
      
      # GET /api/v1/supply_batches/fifo_order
      def fifo_order
        food_item_id = params[:food_item_id]
        @supply_batches = SupplyBatch.fifo_list(food_item_id)
        
        render json: {
          supply_batches: @supply_batches.as_json,
          fifo_order: @supply_batches.map { |b| {
            id: b.id,
            food_item: b.food_item.name,
            batch_code: b.batch_code,
            priority_score: b.priority_score,
            current_quantity: b.current_quantity,
            expiration_date: b.expiration_date,
            entry_date: b.entry_date
          }}
        }
      end
      
      # POST /api/v1/supply_batches/:id/consume
      def consume
        quantity = params[:quantity].to_f
        rotation_type = params[:rotation_type] || 'consumption'
        reason = params[:reason]
        notes = params[:notes]
        
        begin
          rotation = @supply_batch.consume!(
            quantity,
            rotation_type: rotation_type,
            reason: reason,
            notes: notes
          )
          
          render json: {
            supply_batch: @supply_batch.reload.as_json,
            rotation: rotation.as_json
          }, status: :ok
        rescue StandardError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      # GET /api/v1/supply_batches/statistics
      def statistics
        food_item_id = params[:food_item_id]
        
        stats = if food_item_id.present?
          food_item = FoodItem.find(food_item_id)
          food_item.batch_statistics
        else
          {
            total_batches: SupplyBatch.count,
            active_batches: SupplyBatch.active.count,
            depleted_batches: SupplyBatch.depleted.count,
            expired_batches: SupplyBatch.expired.count,
            total_active_quantity: SupplyBatch.active.sum(:current_quantity),
            expiring_soon_count: SupplyBatch.expiring_soon.count
          }
        end
        
        render json: stats
      end
      
      private
      
      def set_supply_batch
        @supply_batch = current_user.supply_batches.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Supply batch not found' }, status: :not_found
      end
      
      def supply_batch_params
        params.require(:supply_batch).permit(
          :food_item_id,
          :initial_quantity,
          :current_quantity,
          :entry_date,
          :expiration_date,
          :batch_code,
          :supplier,
          :unit_cost,
          :notes,
          :status
        )
      end
    end
  end
end

