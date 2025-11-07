class FoodItemsController < ApplicationController
  before_action :set_food_item, only: [:show, :edit, :update, :destroy]

  # GET /food_items
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

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /food_items/:id
  def show
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /food_items/new
  def new
    @food_item = FoodItem.new
  end

  # GET /food_items/:id/edit
  def edit
  end

  # POST /food_items
  def create
    @food_item = FoodItem.new(food_item_params)

    respond_to do |format|
      if @food_item.save
        format.html { redirect_to food_items_path, notice: "Alimento cadastrado com sucesso." }
        format.turbo_stream { 
          flash.now[:notice] = "Alimento cadastrado com sucesso."
        }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /food_items/:id
  def update
    respond_to do |format|
      if @food_item.update(food_item_params)
        format.html { redirect_to food_items_path, notice: "Alimento atualizado com sucesso." }
        format.turbo_stream {
          flash.now[:notice] = "Alimento atualizado com sucesso."
        }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /food_items/:id
  def destroy
    @food_item.destroy

    respond_to do |format|
      format.html { redirect_to food_items_path, notice: "Alimento removido com sucesso." }
      format.turbo_stream {
        flash.now[:notice] = "Alimento removido com sucesso."
      }
    end
  end

  private

  def set_food_item
    @food_item = FoodItem.find(params[:id])
  end

  def food_item_params
    params_hash = params.require(:food_item).permit(
      :name,
      :category,
      :quantity,
      :expiration_date,
      :storage_location,
      :notes
    )
    
    # Converter data do formato brasileiro DD/MM/AAAA para formato do banco AAAA-MM-DD
    if params_hash[:expiration_date].present? && params_hash[:expiration_date].match?(/\d{2}\/\d{2}\/\d{4}/)
      begin
        date_parts = params_hash[:expiration_date].split('/')
        params_hash[:expiration_date] = "#{date_parts[2]}-#{date_parts[1]}-#{date_parts[0]}"
      rescue
        # Se falhar a conversão, mantém o valor original
      end
    end
    
    params_hash
  end
end

