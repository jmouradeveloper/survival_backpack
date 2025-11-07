module Api
  module V1
    class FoodItemsController < BaseController
      before_action :set_food_item, only: [:show, :update, :destroy]

      # GET /api/v1/food_items
      def index
        @food_items = FoodItem.recent

        # Filtros opcionais
        @food_items = @food_items.by_category(params[:category]) if params[:category].present?
        @food_items = @food_items.by_storage_location(params[:storage_location]) if params[:storage_location].present?

        case params[:filter]
        when "expired"
          @food_items = @food_items.expired
        when "expiring_soon"
          @food_items = @food_items.expiring_soon
        when "valid"
          @food_items = @food_items.valid_items
        end

        # Paginação
        page = params[:page]&.to_i || 1
        per_page = params[:per_page]&.to_i || 20
        per_page = 100 if per_page > 100 # Limite máximo

        @food_items = @food_items.limit(per_page).offset((page - 1) * per_page)

        render json: {
          data: @food_items,
          meta: {
            page: page,
            per_page: per_page,
            total: FoodItem.count
          }
        }
      end

      # GET /api/v1/food_items/:id
      def show
        render json: { data: @food_item }
      end

      # POST /api/v1/food_items
      def create
        @food_item = FoodItem.new(food_item_params)

        if @food_item.save
          render json: { 
            data: @food_item, 
            message: "Alimento cadastrado com sucesso" 
          }, status: :created
        else
          render json: { 
            error: "Erro ao cadastrar alimento", 
            details: @food_item.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/food_items/:id
      def update
        if @food_item.update(food_item_params)
          render json: { 
            data: @food_item, 
            message: "Alimento atualizado com sucesso" 
          }
        else
          render json: { 
            error: "Erro ao atualizar alimento", 
            details: @food_item.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/food_items/:id
      def destroy
        @food_item.destroy
        render json: { message: "Alimento removido com sucesso" }
      end

      # GET /api/v1/food_items/statistics
      def statistics
        render json: {
          data: {
            total: FoodItem.count,
            expired: FoodItem.expired.count,
            expiring_soon: FoodItem.expiring_soon.count,
            valid: FoodItem.valid_items.count,
            by_category: FoodItem.group(:category).count,
            by_storage_location: FoodItem.group(:storage_location).count
          }
        }
      end

      private

      def set_food_item
        @food_item = FoodItem.find(params[:id])
      end

      def food_item_params
        params.require(:food_item).permit(
          :name,
          :category,
          :quantity,
          :expiration_date,
          :storage_location,
          :notes
        )
      end
    end
  end
end

