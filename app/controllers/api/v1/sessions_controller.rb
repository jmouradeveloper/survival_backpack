module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_api_user!, only: [:create]

      def create
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = user.generate_api_token(
            name: params[:token_name] || "API Token",
            expires_in: params[:expires_in]&.to_i&.days || 90.days
          )
          
          user.update_last_login!

          render json: {
            token: token.raw_token,
            user: {
              id: user.id,
              email: user.email,
              role: user.role
            },
            expires_at: token.expires_at
          }, status: :created
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def destroy
        current_api_token&.revoke!
        render json: { message: "Token revoked successfully" }, status: :ok
      end
    end
  end
end

