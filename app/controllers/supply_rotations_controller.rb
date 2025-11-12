class SupplyRotationsController < ApplicationController
  include Authorization
  before_action :set_supply_rotation, only: [:show, :destroy]
  
  # GET /supply_rotations
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
    
    @supply_rotations = @supply_rotations.recent.page(params[:page]).per(20)
    
    # Estatísticas
    rotations_scope = current_user.supply_rotations
    rotations_scope = rotations_scope.by_date_range(Date.parse(params[:start_date]), Date.parse(params[:end_date])) if params[:start_date].present? && params[:end_date].present?
    @statistics = SupplyRotation.statistics(
      params[:start_date].present? ? Date.parse(params[:start_date]) : nil,
      params[:end_date].present? ? Date.parse(params[:end_date]) : nil
    )
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  # GET /supply_rotations/:id
  def show
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  # GET /supply_rotations/new
  def new
    @supply_rotation = current_user.supply_rotations.new
    @supply_rotation.rotation_date = Date.today
    
    # Se vier de um food_item ou batch específico, pré-preenche
    if params[:food_item_id].present?
      @food_item = current_user.food_items.find(params[:food_item_id])
      @supply_rotation.food_item = @food_item
      @available_batches = @food_item.active_batches
    end
    
    if params[:supply_batch_id].present?
      @supply_batch = current_user.supply_batches.find(params[:supply_batch_id])
      @supply_rotation.supply_batch = @supply_batch
      @supply_rotation.food_item = @supply_batch.food_item
    end
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  # POST /supply_rotations
  def create
    @supply_batch = current_user.supply_batches.find(supply_rotation_params[:supply_batch_id])
    quantity = supply_rotation_params[:quantity].to_f
    
    begin
      @supply_rotation = @supply_batch.consume!(
        quantity,
        rotation_type: supply_rotation_params[:rotation_type],
        reason: supply_rotation_params[:reason],
        notes: supply_rotation_params[:notes]
      )
      
      respond_to do |format|
        format.html { 
          redirect_to supply_rotations_path, 
          notice: 'Rotação registrada com sucesso.' 
        }
        format.turbo_stream { 
          flash.now[:notice] = 'Rotação registrada com sucesso.'
        }
      end
    rescue StandardError => e
      @supply_rotation = SupplyRotation.new(supply_rotation_params)
      
      respond_to do |format|
        format.html { 
          flash.now[:alert] = "Erro: #{e.message}"
          render :new, status: :unprocessable_entity 
        }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            'supply_rotation_form',
            partial: 'form',
            locals: { supply_rotation: @supply_rotation, error: e.message }
          ), status: :unprocessable_entity
        }
      end
    end
  end
  
  # DELETE /supply_rotations/:id
  def destroy
    @supply_rotation.destroy
    
    respond_to do |format|
      format.html { 
        redirect_to supply_rotations_path, 
        notice: 'Registro de rotação removido.' 
      }
      format.turbo_stream {
        flash.now[:notice] = 'Registro de rotação removido.'
      }
    end
  end
  
  # POST /supply_rotations/consume_fifo
  def consume_fifo
    @food_item = current_user.food_items.find(params[:food_item_id])
    quantity = params[:quantity].to_f
    rotation_type = params[:rotation_type] || 'consumption'
    reason = params[:reason]
    notes = params[:notes]
    
    begin
      @rotations = @food_item.consume_fifo!(
        quantity,
        rotation_type: rotation_type,
        reason: reason,
        notes: notes
      )
      
      respond_to do |format|
        format.html { 
          redirect_to food_item_path(@food_item), 
          notice: "Consumo FIFO de #{quantity} registrado com sucesso." 
        }
        format.turbo_stream { 
          flash.now[:notice] = "Consumo FIFO de #{quantity} registrado com sucesso."
        }
      end
    rescue StandardError => e
      respond_to do |format|
        format.html { 
          redirect_to food_item_path(@food_item), 
          alert: "Erro ao registrar consumo FIFO: #{e.message}" 
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
  
  # GET /supply_rotations/statistics
  def statistics
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
    
    @statistics = SupplyRotation.statistics(start_date, end_date)
    @food_item = current_user.food_items.find(params[:food_item_id]) if params[:food_item_id].present?
    
    respond_to do |format|
      format.html
      format.turbo_stream
      format.json { render json: @statistics }
    end
  end
  
  private
  
  def set_supply_rotation
    @supply_rotation = current_user.supply_rotations.find(params[:id])
  end
  
  def supply_rotation_params
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

