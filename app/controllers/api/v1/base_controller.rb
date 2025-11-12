module Api
  module V1
    class BaseController < ApplicationController
      # Desabilitar proteção CSRF para APIs
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user!
      
      before_action :authenticate_api_user!
      
      attr_reader :current_api_token

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

      private

      def authenticate_api_user!
        token = extract_token_from_header
        
        if token.blank?
          render json: { error: "Missing authorization token" }, status: :unauthorized
          return
        end
        
        @current_api_token = ApiToken.find_by_token(token)
        
        if @current_api_token.nil?
          render json: { error: "Invalid authorization token" }, status: :unauthorized
          return
        end
        
        if @current_api_token.expired?
          render json: { error: "Token has expired" }, status: :unauthorized
          return
        end
        
        # Set current user for this request
        Current.user = @current_api_token.user
        @current_api_token.mark_as_used!
      end
      
      def extract_token_from_header
        auth_header = request.headers["Authorization"]
        return nil if auth_header.blank?
        
        # Expected format: "Bearer TOKEN"
        auth_header.split(" ").last if auth_header.start_with?("Bearer ")
      end

      def not_found
        render json: { error: "Recurso não encontrado" }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { 
          error: "Erro de validação", 
          details: exception.record.errors.full_messages 
        }, status: :unprocessable_entity
      end
    end
  end
end

