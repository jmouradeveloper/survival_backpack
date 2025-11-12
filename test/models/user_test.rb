require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
  end
  
  test "should be valid with valid attributes" do
    assert @user.valid?
  end
  
  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end
  
  test "should require unique email" do
    @user.save
    duplicate_user = @user.dup
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end
  
  test "should normalize email to lowercase" do
    @user.email = "TEST@EXAMPLE.COM"
    @user.save
    assert_equal "test@example.com", @user.email
  end
  
  test "should validate email format" do
    invalid_emails = ["invalid", "@example.com", "test@", "test spaces@example.com"]
    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?, "#{invalid_email} should be invalid"
    end
  end
  
  test "should require password on create" do
    user = User.new(email: "test@example.com")
    assert_not user.valid?
  end
  
  test "should require minimum password length" do
    @user.password = @user.password_confirmation = "Pass1!"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 8 characters)"
  end
  
  test "should require password complexity" do
    invalid_passwords = [
      "password123!",  # no uppercase
      "PASSWORD123!",  # no lowercase
      "Password!",     # no digit
      "Password123"    # no special char
    ]
    
    invalid_passwords.each do |invalid_password|
      @user.password = @user.password_confirmation = invalid_password
      assert_not @user.valid?, "#{invalid_password} should require more complexity"
    end
  end
  
  test "should authenticate with correct password" do
    @user.save
    assert @user.authenticate("Password123!")
  end
  
  test "should not authenticate with incorrect password" do
    @user.save
    assert_not @user.authenticate("wrongpassword")
  end
  
  test "should have default user role" do
    assert_equal "user", @user.role
  end
  
  test "should allow admin role" do
    @user.role = :admin
    assert @user.valid?
    assert @user.admin?
  end
  
  test "should detect session expiration" do
    @user.save
    @user.update(last_login_at: 31.days.ago)
    assert @user.session_expired?
  end
  
  test "should not expire session within 30 days" do
    @user.save
    @user.update(last_login_at: 29.days.ago)
    assert_not @user.session_expired?
  end
  
  test "should update last login" do
    @user.save
    travel_to Time.current do
      @user.update_last_login!
      assert_equal Time.current.to_i, @user.last_login_at.to_i
    end
  end
  
  test "should generate api token" do
    @user.save
    token = @user.generate_api_token
    assert token.persisted?
    assert_equal @user, token.user
    assert token.raw_token.present?
  end
  
  test "should create notification preference on creation" do
    assert_difference "NotificationPreference.count", 1 do
      @user.save
    end
    assert @user.notification_preference.present?
  end
  
  test "should have associated food items" do
    @user.save
    food_item = @user.food_items.create!(name: "Test Food", category: "Grains", quantity: 10)
    assert_includes @user.food_items, food_item
  end
end
