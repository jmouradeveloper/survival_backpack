class ApiToken < ApplicationRecord
  belongs_to :user
  
  # Callbacks
  before_create :generate_token
  before_create :set_default_expiration
  
  # Validations
  validates :token_digest, presence: true, uniqueness: true
  validates :name, presence: true
  
  # Scopes
  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at IS NOT NULL AND expires_at <= ?", Time.current) }
  scope :recently_used, -> { where("last_used_at > ?", 1.week.ago) }
  
  # Virtual attribute for the raw token (only available when created)
  attr_accessor :raw_token
  
  # Class methods
  def self.find_by_token(token)
    return nil if token.blank?
    
    # Hash the incoming token and search for it
    digest = hash_token(token)
    active.find_by(token_digest: digest)
  end
  
  def self.hash_token(token)
    Digest::SHA256.hexdigest(token)
  end
  
  # Instance methods
  def expired?
    expires_at.present? && expires_at <= Time.current
  end
  
  def mark_as_used!
    update_column(:last_used_at, Time.current)
  end
  
  def revoke!
    update!(expires_at: Time.current)
  end
  
  def token_preview
    return nil unless raw_token
    "#{raw_token[0..7]}...#{raw_token[-4..]}"
  end
  
  private
  
  def generate_token
    loop do
      self.raw_token = SecureRandom.base58(32)
      self.token_digest = self.class.hash_token(raw_token)
      break unless ApiToken.exists?(token_digest: token_digest)
    end
  end
  
  def set_default_expiration
    self.expires_at ||= 90.days.from_now
  end
end
