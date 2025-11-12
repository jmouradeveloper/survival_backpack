ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Helper para criar usuário de teste
    def create_test_user(email: "test@example.com", role: :user)
      User.create!(
        email: email,
        password: "Password123!",
        password_confirmation: "Password123!",
        role: role
      )
    end
    
    # Helper para obter o usuário padrão dos fixtures
    def regular_user
      users(:regular_user)
    end
    
    def admin_user
      users(:admin)
    end
  end
end

module ActionDispatch
  class IntegrationTest
    # Helper para autenticação em integration tests
    def sign_in(user)
      post login_url, params: { 
        email: user.email, 
        password: "Password123!" 
      }
    end
    
    # Helper para autenticação via API
    def api_auth_headers(token)
      { "Authorization" => "Bearer #{token}" }
    end
    
    # Helper para fazer login via API e retornar token
    def api_sign_in(user)
      post api_v1_login_url, params: {
        email: user.email,
        password: "Password123!"
      }
      JSON.parse(@response.body)["token"]
    end
  end
end
