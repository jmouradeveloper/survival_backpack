class FoodItem < ApplicationRecord
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

