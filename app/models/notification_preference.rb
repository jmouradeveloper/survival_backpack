class NotificationPreference < ApplicationRecord
  # Validações
  validates :days_before_expiration, presence: true, numericality: { 
    only_integer: true, 
    greater_than_or_equal_to: 1, 
    less_than_or_equal_to: 365 
  }

  # Callbacks
  after_initialize :set_defaults, if: :new_record?

  # Singleton pattern - apenas uma preferência por sistema
  # Em uma aplicação multi-usuário, você adicionaria um belongs_to :user
  def self.current
    first_or_create!
  end

  def self.days_before_expiration_value
    current.days_before_expiration
  end

  # Métodos para gerenciar subscription de push
  def push_subscription=(subscription_data)
    if subscription_data.is_a?(Hash)
      self.push_subscription_endpoint = subscription_data['endpoint']
      self.push_subscription_keys = subscription_data['keys'].to_json if subscription_data['keys']
    end
  end

  def push_subscription
    return nil unless push_subscription_endpoint.present?
    
    {
      endpoint: push_subscription_endpoint,
      keys: push_subscription_keys.present? ? JSON.parse(push_subscription_keys) : {}
    }
  end

  def push_notifications_enabled?
    enable_push_notifications && push_subscription_endpoint.present?
  end

  # Serialização para API
  def as_json(options = {})
    super(options.merge(
      except: [:push_subscription_keys],
      methods: [:push_notifications_enabled?]
    ))
  end

  private

  def set_defaults
    self.days_before_expiration ||= 7
    self.enable_push_notifications = true if enable_push_notifications.nil?
    self.enable_email_notifications = false if enable_email_notifications.nil?
  end
end

