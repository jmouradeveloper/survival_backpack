module Api
  module V1
    class ApiTokensController < BaseController
      def index
        tokens = current_user.api_tokens.order(created_at: :desc)
        
        render json: tokens.map { |token|
          {
            id: token.id,
            name: token.name,
            last_used_at: token.last_used_at,
            expires_at: token.expires_at,
            created_at: token.created_at,
            expired: token.expired?
          }
        }
      end

      def create
        token = current_user.api_tokens.build(api_token_params)

        if token.save
          render json: {
            id: token.id,
            name: token.name,
            token: token.raw_token,
            expires_at: token.expires_at,
            created_at: token.created_at,
            message: "Token created successfully. Make sure to save it - you won't be able to see it again!"
          }, status: :created
        else
          render json: { errors: token.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        token = current_user.api_tokens.find(params[:id])
        token.destroy
        
        render json: { message: "Token revoked successfully" }, status: :ok
      end

      private

      def api_token_params
        params.require(:api_token).permit(:name, :expires_in).tap do |p|
          p[:expires_at] = p.delete(:expires_in)&.to_i&.days&.from_now if p[:expires_in]
        end
      end
    end
  end
end

