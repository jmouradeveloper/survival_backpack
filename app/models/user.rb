class User < ApplicationRecord
  has_secure_password
  
  # Associations
  has_many :api_tokens, dependent: :destroy
  has_many :food_items, dependent: :destroy
  has_many :supply_batches, dependent: :destroy
  has_many :supply_rotations, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one :notification_preference, dependent: :destroy
  
  # Enums
  enum :role, { user: 0, admin: 1 }, default: :user
  
  # Validations
  validates :email, presence: true, 
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?
  validates :password, format: { 
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
    message: "must include at least one lowercase letter, one uppercase letter, one digit, and one special character"
  }, if: :password_digest_changed?
  
  # Callbacks
  before_save :normalize_email
  after_create :create_default_notification_preference
  
  # Scopes
  scope :admins, -> { where(role: :admin) }
  scope :regular_users, -> { where(role: :user) }
  scope :recent_login, -> { where("last_login_at > ?", 30.days.ago) }
  scope :inactive, -> { where("last_login_at <= ? OR last_login_at IS NULL", 30.days.ago) }
  
  # Methods
  def session_expired?
    last_login_at.present? && last_login_at < 30.days.ago
  end
  
  def update_last_login!
    update_column(:last_login_at, Time.current)
  end
  
  def generate_api_token(name: "Default Token", expires_in: 90.days)
    api_tokens.create!(
      name: name,
      expires_at: expires_in.from_now
    )
  end
  
  private
  
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
  
  def create_default_notification_preference
    build_notification_preference.save
  end
end
