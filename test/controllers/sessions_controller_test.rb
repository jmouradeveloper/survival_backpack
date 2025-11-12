require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
  end

  test "should get new" do
    get login_url
    assert_response :success
  end

  test "should login with valid credentials" do
    post login_url, params: { email: @user.email, password: "Password123!" }
    assert_redirected_to root_path
    assert_equal @user.id, session[:user_id]
  end

  test "should not login with invalid password" do
    post login_url, params: { email: @user.email, password: "wrong" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "should not login with invalid email" do
    post login_url, params: { email: "wrong@example.com", password: "Password123!" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "should logout" do
    post login_url, params: { email: @user.email, password: "Password123!" }
    assert_equal @user.id, session[:user_id]
    
    delete logout_url
    assert_redirected_to login_path
    assert_nil session[:user_id]
  end

  test "should redirect to root if already logged in" do
    post login_url, params: { email: @user.email, password: "Password123!" }
    get login_url
    assert_redirected_to root_path
  end

  test "should update last_login_at on successful login" do
    travel_to Time.current do
      post login_url, params: { email: @user.email, password: "Password123!" }
      @user.reload
      assert_equal Time.current.to_i, @user.last_login_at.to_i
    end
  end
end
