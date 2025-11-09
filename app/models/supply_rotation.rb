class SupplyRotation < ApplicationRecord
  # Associações
  belongs_to :supply_batch
  belongs_to :food_item
  
  # Validações
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :rotation_date, presence: true
  validates :rotation_type, presence: true, inclusion: { in: %w[consumption waste donation transfer] }
  
  # Scopes
  scope :consumption, -> { where(rotation_type: 'consumption') }
  scope :waste, -> { where(rotation_type: 'waste') }
  scope :donation, -> { where(rotation_type: 'donation') }
  scope :transfer, -> { where(rotation_type: 'transfer') }
  scope :by_date_range, ->(start_date, end_date) { 
    where(rotation_date: start_date..end_date) 
  }
  scope :by_type, ->(type) { where(rotation_type: type) }
  scope :by_food_item, ->(food_item_id) { where(food_item_id: food_item_id) }
  scope :recent, -> { order(rotation_date: :desc, created_at: :desc) }
  scope :this_month, -> { 
    where(rotation_date: Date.today.beginning_of_month..Date.today.end_of_month) 
  }
  scope :this_year, -> { 
    where(rotation_date: Date.today.beginning_of_year..Date.today.end_of_year) 
  }
  
  # Métodos de classe
  def self.total_consumed(food_item_id = nil)
    rotations = consumption
    rotations = rotations.by_food_item(food_item_id) if food_item_id.present?
    rotations.sum(:quantity)
  end
  
  def self.total_wasted(food_item_id = nil)
    rotations = waste
    rotations = rotations.by_food_item(food_item_id) if food_item_id.present?
    rotations.sum(:quantity)
  end
  
  def self.statistics(start_date = nil, end_date = nil)
    rotations = all
    rotations = rotations.by_date_range(start_date, end_date) if start_date && end_date
    
    {
      total_rotations: rotations.count,
      total_quantity: rotations.sum(:quantity),
      by_type: {
        consumption: rotations.consumption.sum(:quantity),
        waste: rotations.waste.sum(:quantity),
        donation: rotations.donation.sum(:quantity),
        transfer: rotations.transfer.sum(:quantity)
      },
      waste_percentage: calculate_waste_percentage(rotations)
    }
  end
  
  def self.calculate_waste_percentage(rotations = nil)
    rotations ||= all
    total = rotations.sum(:quantity)
    return 0 if total.zero?
    
    waste_total = rotations.waste.sum(:quantity)
    ((waste_total.to_f / total) * 100).round(2)
  end
  
  # Métodos de instância
  def batch_info
    {
      batch_code: supply_batch.batch_code,
      entry_date: supply_batch.entry_date,
      expiration_date: supply_batch.expiration_date
    }
  end
  
  # Serialização para API
  def as_json(options = {})
    super(options.merge(
      include: {
        food_item: { only: [:id, :name, :category] },
        supply_batch: { only: [:id, :batch_code, :entry_date, :expiration_date] }
      }
    ))
  end
end

