class SupplyBatch < ApplicationRecord
  # Associações
  belongs_to :food_item
  has_many :supply_rotations, dependent: :destroy
  
  # Validações
  validates :initial_quantity, presence: true, numericality: { greater_than: 0 }
  validates :current_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :entry_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[active depleted expired] }
  validate :current_quantity_cannot_exceed_initial
  validate :expiration_date_must_be_after_entry_date
  
  # Callbacks
  before_validation :set_current_quantity, on: :create
  after_create :update_food_item_quantity
  after_update :update_food_item_quantity
  after_update :check_and_update_status
  
  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :depleted, -> { where(status: 'depleted') }
  scope :expired, -> { where(status: 'expired') }
  scope :expiring_soon, ->(days = 7) { 
    where("expiration_date <= ? AND expiration_date >= ? AND status = ?", 
          Date.today + days.days, Date.today, 'active') 
  }
  scope :by_fifo_order, -> { 
    order(Arel.sql("
      CASE 
        WHEN expiration_date IS NOT NULL THEN expiration_date
        ELSE entry_date
      END ASC
    ")) 
  }
  scope :by_food_item, ->(food_item_id) { where(food_item_id: food_item_id) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Métodos de classe
  def self.next_to_consume(food_item_id = nil)
    batches = active
    batches = batches.by_food_item(food_item_id) if food_item_id.present?
    batches.by_fifo_order.first
  end
  
  def self.fifo_list(food_item_id = nil)
    batches = active
    batches = batches.by_food_item(food_item_id) if food_item_id.present?
    batches.by_fifo_order
  end
  
  # Métodos de instância
  def expired?
    expiration_date.present? && expiration_date < Date.today
  end
  
  def expiring_soon?(days = 7)
    expiration_date.present? && 
    expiration_date <= Date.today + days.days && 
    !expired?
  end
  
  def days_until_expiration
    return nil if expiration_date.nil?
    (expiration_date - Date.today).to_i
  end
  
  def consumed_quantity
    initial_quantity - current_quantity
  end
  
  def consumption_percentage
    return 0 if initial_quantity.zero?
    ((consumed_quantity / initial_quantity) * 100).round(2)
  end
  
  def available?
    active? && current_quantity > 0 && !expired?
  end
  
  def priority_score
    # Menor score = maior prioridade (FIFO)
    return Float::INFINITY unless available?
    
    base_score = if expiration_date.present?
      days_until_expiration || 0
    else
      (Date.today - entry_date).to_i + 1000 # Sem validade tem prioridade menor
    end
    
    # Ajusta score se estiver vencido ou com pouca quantidade
    base_score -= 10000 if expired?
    base_score -= 100 if current_quantity < (initial_quantity * 0.1) # Menos de 10%
    
    base_score
  end
  
  # Consome uma quantidade do lote (FIFO)
  def consume!(quantity, rotation_type: 'consumption', reason: nil, notes: nil)
    raise ArgumentError, "Quantity must be positive" if quantity <= 0
    raise ArgumentError, "Insufficient quantity in batch" if quantity > current_quantity
    
    transaction do
      # Cria registro de rotação
      rotation = supply_rotations.create!(
        food_item: food_item,
        quantity: quantity,
        rotation_date: Date.today,
        rotation_type: rotation_type,
        reason: reason,
        notes: notes
      )
      
      # Atualiza quantidade atual
      self.current_quantity -= quantity
      
      # Atualiza status se necessário
      self.status = 'depleted' if current_quantity.zero?
      
      save!
      rotation
    end
  end
  
  # Serialização para API
  def as_json(options = {})
    super(options.merge(
      include: { food_item: { only: [:id, :name, :category] } },
      methods: [
        :expired?, 
        :expiring_soon?, 
        :days_until_expiration, 
        :consumed_quantity,
        :consumption_percentage,
        :available?,
        :priority_score
      ]
    ))
  end
  
  private
  
  def set_current_quantity
    self.current_quantity ||= initial_quantity
  end
  
  def current_quantity_cannot_exceed_initial
    if current_quantity.present? && initial_quantity.present? && 
       current_quantity > initial_quantity
      errors.add(:current_quantity, "cannot exceed initial quantity")
    end
  end
  
  def expiration_date_must_be_after_entry_date
    if expiration_date.present? && entry_date.present? && 
       expiration_date < entry_date
      errors.add(:expiration_date, "must be after entry date")
    end
  end
  
  def update_food_item_quantity
    # Recalcula a quantidade total do food_item baseado nos lotes ativos
    total = food_item.supply_batches.active.sum(:current_quantity)
    food_item.update_column(:quantity, total)
  end
  
  def check_and_update_status
    if current_quantity.zero? && !depleted?
      update_column(:status, 'depleted')
    elsif expired? && !expired?
      update_column(:status, 'expired')
    end
  end
end

