class Notification < ApplicationRecord
  belongs_to :food_item

  # Validações
  validates :title, presence: true
  validates :notification_type, presence: true
  validates :read, inclusion: { in: [true, false] }

  # Tipos de notificação
  TYPES = {
    expiration_warning: 'expiration_warning',
    expiration_urgent: 'expiration_urgent',
    expired: 'expired'
  }.freeze

  # Prioridades
  PRIORITIES = {
    low: 0,
    medium: 1,
    high: 2
  }.freeze

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :read_notifications, -> { where(read: true) }
  scope :by_type, ->(type) { where(notification_type: type) }
  scope :scheduled, -> { where.not(scheduled_for: nil).where('scheduled_for > ?', Time.current) }
  scope :pending_to_send, -> { where(sent_at: nil).where('scheduled_for <= ? OR scheduled_for IS NULL', Time.current) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_priority, -> { order(priority: :desc, created_at: :desc) }

  # Callbacks
  before_create :set_scheduled_time, unless: :scheduled_for?

  # Métodos de instância
  def mark_as_read!
    update(read: true)
  end

  def mark_as_unread!
    update(read: false)
  end

  def send_notification!
    return if sent_at.present?
    
    update(sent_at: Time.current)
    broadcast_notification
  end

  def broadcast_notification
    # Broadcast via Turbo Stream para atualização em tempo real
    broadcast_prepend_to(
      "notifications",
      partial: "notifications/notification",
      locals: { notification: self },
      target: "notifications_list"
    )
  end

  # Serialização para API
  def as_json(options = {})
    super(options.merge(
      include: {
        food_item: {
          only: [:id, :name, :category, :expiration_date, :storage_location]
        }
      }
    ))
  end

  private

  def set_scheduled_time
    self.scheduled_for = Time.current
  end
end

