module Api
  module V1
    class BaseController < ApplicationController
      # Desabilitar proteção CSRF para APIs
      skip_before_action :verify_authenticity_token

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

      private

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

