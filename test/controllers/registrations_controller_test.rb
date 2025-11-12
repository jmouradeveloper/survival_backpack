require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_url
    assert_response :success
  end

  test "should create user with valid attributes" do
    assert_difference("User.count") do
      post signup_url, params: {
        user: {
          email: "newuser@example.com",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end
    assert_redirected_to root_path
    assert session[:user_id].present?
  end

  test "should not create user with invalid email" do
    assert_no_difference("User.count") do
      post signup_url, params: {
        user: {
          email: "invalid",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create user with weak password" do
    assert_no_difference("User.count") do
      post signup_url, params: {
        user: {
          email: "newuser@example.com",
          password: "weak",
          password_confirmation: "weak"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create user with mismatched passwords" do
    assert_no_difference("User.count") do
      post signup_url, params: {
        user: {
          email: "newuser@example.com",
          password: "Password123!",
          password_confirmation: "Different123!"
        }
      }
    end
    assert_response :unprocessable_entity
  end
end
