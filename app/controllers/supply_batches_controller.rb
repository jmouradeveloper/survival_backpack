class SupplyBatchesController < ApplicationController
  before_action :set_supply_batch, only: [:show, :edit, :update, :destroy]
  before_action :set_food_items, only: [:new, :edit, :create, :update]
  
  # GET /supply_batches
  def index
    @supply_batches = SupplyBatch.includes(:food_item)
    
    # Filtros
    @supply_batches = @supply_batches.by_food_item(params[:food_item_id]) if params[:food_item_id].present?
    @supply_batches = @supply_batches.where(status: params[:status]) if params[:status].present?
    
    # Ordenação
    @supply_batches = if params[:sort] == 'recent'
      @supply_batches.recent
    else
      @supply_batches.by_fifo_order
    end
    
    @supply_batches = @supply_batches.page(params[:page]).per(20)
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  # GET /supply_batches/:id
  def show
    @rotations = @supply_batch.supply_rotations.recent.limit(10)
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  # GET /supply_batches/new
  def new
    @supply_batch = SupplyBatch.new
    @supply_batch.entry_date = Date.today
    
    # Se vier de um food_item específico, pré-preenche
    if params[:food_item_id].present?
      @supply_batch.food_item_id = params[:food_item_id]
      @food_item = FoodItem.find(params[:food_item_id])
    end
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  # GET /supply_batches/:id/edit
  def edit
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  # POST /supply_batches
  def create
    @supply_batch = SupplyBatch.new(supply_batch_params)
    
    respond_to do |format|
      if @supply_batch.save
        format.html { 
          redirect_to supply_batches_path, 
          notice: 'Lote criado com sucesso.' 
        }
        format.turbo_stream { 
          flash.now[:notice] = 'Lote criado com sucesso.'
        }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            'supply_batch_form',
            partial: 'form',
            locals: { supply_batch: @supply_batch }
          ), status: :unprocessable_entity
        }
      end
    end
  end
  
  # PATCH/PUT /supply_batches/:id
  def update
    respond_to do |format|
      if @supply_batch.update(supply_batch_params)
        format.html { 
          redirect_to supply_batches_path, 
          notice: 'Lote atualizado com sucesso.' 
        }
        format.turbo_stream {
          flash.now[:notice] = 'Lote atualizado com sucesso.'
        }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            'supply_batch_form',
            partial: 'form',
            locals: { supply_batch: @supply_batch }
          ), status: :unprocessable_entity
        }
      end
    end
  end
  
  # DELETE /supply_batches/:id
  def destroy
    @supply_batch.destroy
    
    respond_to do |format|
      format.html { 
        redirect_to supply_batches_path, 
        notice: 'Lote removido com sucesso.' 
      }
      format.turbo_stream {
        flash.now[:notice] = 'Lote removido com sucesso.'
      }
    end
  end
  
  # GET /supply_batches/fifo_order
  def fifo_order
    @food_item = params[:food_item_id].present? ? FoodItem.find(params[:food_item_id]) : nil
    @supply_batches = SupplyBatch.active
    @supply_batches = @supply_batches.by_food_item(@food_item.id) if @food_item
    @supply_batches = @supply_batches.by_fifo_order
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  # POST /supply_batches/:id/consume
  def consume
    @supply_batch = SupplyBatch.find(params[:id])
    quantity = params[:quantity].to_f
    rotation_type = params[:rotation_type] || 'consumption'
    reason = params[:reason]
    notes = params[:notes]
    
    begin
      @rotation = @supply_batch.consume!(
        quantity,
        rotation_type: rotation_type,
        reason: reason,
        notes: notes
      )
      
      respond_to do |format|
        format.html { 
          redirect_to @supply_batch, 
          notice: 'Consumo registrado com sucesso.' 
        }
        format.turbo_stream {
          flash.now[:notice] = 'Consumo registrado com sucesso.'
        }
      end
    rescue StandardError => e
      respond_to do |format|
        format.html { 
          redirect_to @supply_batch, 
          alert: "Erro ao registrar consumo: #{e.message}" 
        }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            'flash',
            partial: 'shared/flash',
            locals: { flash: { alert: "Erro: #{e.message}" } }
          ), status: :unprocessable_entity
        }
      end
    end
  end
  
  private
  
  def set_supply_batch
    @supply_batch = SupplyBatch.find(params[:id])
  end
  
  def set_food_items
    @food_items = FoodItem.order(:name)
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

