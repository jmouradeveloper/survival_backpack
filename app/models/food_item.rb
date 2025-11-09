class FoodItem < ApplicationRecord
  # Associações
  has_many :notifications, dependent: :destroy
  has_many :supply_batches, dependent: :destroy
  has_many :supply_rotations, dependent: :destroy

  # Validações
  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :category, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :storage_location, length: { maximum: 255 }, allow_blank: true
  validates :notes, length: { maximum: 5000 }, allow_blank: true
  
  # Validação customizada para data de validade
  validate :expiration_date_must_be_future, if: -> { expiration_date.present? }

  # Scopes úteis
  scope :by_category, ->(category) { where(category: category) }
  scope :expiring_soon, ->(days = 7) { where("expiration_date <= ?", Date.today + days.days) }
  scope :expired, -> { where("expiration_date < ?", Date.today) }
  scope :valid_items, -> { where("expiration_date >= ? OR expiration_date IS NULL", Date.today) }
  scope :by_storage_location, ->(location) { where(storage_location: location) }
  scope :recent, -> { order(created_at: :desc) }

  # Métodos de instância
  def expired?
    expiration_date.present? && expiration_date < Date.today
  end

  def expiring_soon?(days = 7)
    expiration_date.present? && expiration_date <= Date.today + days.days && !expired?
  end

  def days_until_expiration
    return nil if expiration_date.nil?
    (expiration_date - Date.today).to_i
  end

  def status
    return :expired if expired?
    return :expiring_soon if expiring_soon?
    :valid
  end
  
  # Métodos FIFO
  def active_batches
    supply_batches.active.by_fifo_order
  end
  
  def next_batch_to_consume
    supply_batches.next_to_consume(id)
  end
  
  def total_batch_quantity
    supply_batches.active.sum(:current_quantity)
  end
  
  def consume_fifo!(quantity, rotation_type: 'consumption', reason: nil, notes: nil)
    raise ArgumentError, "Quantity must be positive" if quantity <= 0
    raise ArgumentError, "Insufficient quantity available" if quantity > total_batch_quantity
    
    remaining_to_consume = quantity
    rotations = []
    
    transaction do
      active_batches.each do |batch|
        break if remaining_to_consume <= 0
        
        consume_from_batch = [remaining_to_consume, batch.current_quantity].min
        rotation = batch.consume!(
          consume_from_batch,
          rotation_type: rotation_type,
          reason: reason,
          notes: notes
        )
        
        rotations << rotation
        remaining_to_consume -= consume_from_batch
      end
      
      # Atualiza a quantidade total do food_item
      reload
    end
    
    rotations
  end
  
  def batch_statistics
    {
      total_batches: supply_batches.count,
      active_batches: supply_batches.active.count,
      depleted_batches: supply_batches.depleted.count,
      expired_batches: supply_batches.expired.count,
      total_quantity: total_batch_quantity,
      oldest_batch_date: supply_batches.active.minimum(:entry_date),
      next_expiration_date: supply_batches.active.where.not(expiration_date: nil).minimum(:expiration_date)
    }
  end

  # Serialização para API
  def as_json(options = {})
    super(options.merge(
      methods: [:expired?, :expiring_soon?, :days_until_expiration, :status]
    ))
  end
  
  private
  
  def expiration_date_must_be_future
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, :greater_than, count: I18n.l(Date.today, format: :short))
    end
  end
end

