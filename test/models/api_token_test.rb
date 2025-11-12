require "test_helper"

class ApiTokenTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
  end
  
  test "should create token with generated token_digest" do
    token = @user.api_tokens.create!(name: "Test Token")
    assert token.token_digest.present?
    assert token.raw_token.present?
  end
  
  test "should require user" do
    token = ApiToken.new(name: "Test Token")
    assert_not token.valid?
    assert_includes token.errors[:user], "must exist"
  end
  
  test "should require name" do
    token = @user.api_tokens.build
    assert_not token.valid?
    assert_includes token.errors[:name], "can't be blank"
  end
  
  test "should require unique token_digest" do
    token1 = @user.api_tokens.create!(name: "Token 1")
    token2 = @user.api_tokens.build(name: "Token 2")
    token2.token_digest = token1.token_digest
    assert_not token2.valid?
  end
  
  test "should set default expiration" do
    token = @user.api_tokens.create!(name: "Test Token")
    assert token.expires_at.present?
    assert token.expires_at > Time.current
  end
  
  test "should find token by raw token" do
    token = @user.api_tokens.create!(name: "Test Token")
    raw_token = token.raw_token
    
    found_token = ApiToken.find_by_token(raw_token)
    assert_equal token, found_token
  end
  
  test "should not find token with invalid token" do
    found_token = ApiToken.find_by_token("invalid_token")
    assert_nil found_token
  end
  
  test "should detect expired token" do
    token = @user.api_tokens.create!(name: "Test Token")
    token.update(expires_at: 1.day.ago)
    assert token.expired?
  end
  
  test "should not be expired if no expiration date" do
    token = @user.api_tokens.create!(name: "Test Token")
    token.update(expires_at: nil)
    assert_not token.expired?
  end
  
  test "should mark as used" do
    token = @user.api_tokens.create!(name: "Test Token")
    travel_to Time.current do
      token.mark_as_used!
      assert_equal Time.current.to_i, token.last_used_at.to_i
    end
  end
  
  test "should revoke token" do
    token = @user.api_tokens.create!(name: "Test Token")
    travel_to Time.current do
      token.revoke!
      assert_equal Time.current.to_i, token.expires_at.to_i
      assert token.expired?
    end
  end
  
  test "should return active tokens" do
    active_token = @user.api_tokens.create!(name: "Active Token")
    expired_token = @user.api_tokens.create!(name: "Expired Token", expires_at: 1.day.ago)
    
    active_tokens = ApiToken.active
    assert_includes active_tokens, active_token
    assert_not_includes active_tokens, expired_token
  end
  
  test "should hash tokens consistently" do
    token_string = "test_token_123"
    hash1 = ApiToken.hash_token(token_string)
    hash2 = ApiToken.hash_token(token_string)
    assert_equal hash1, hash2
  end
  
  test "should not expose raw token after save" do
    token = @user.api_tokens.create!(name: "Test Token")
    raw_token = token.raw_token
    
    # Reload from database
    reloaded_token = ApiToken.find(token.id)
    assert_nil reloaded_token.raw_token
    assert reloaded_token.token_digest.present?
  end
end
