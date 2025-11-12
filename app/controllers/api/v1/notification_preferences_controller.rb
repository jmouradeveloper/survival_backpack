module Api
  module V1
    class NotificationPreferencesController < Api::V1::BaseController
      before_action :set_preference

      # GET /api/v1/notification_preferences
      def show
        render json: @preference
      end

      # PATCH/PUT /api/v1/notification_preferences
      def update
        if @preference.update(preference_params)
          render json: @preference
        else
          render json: { errors: @preference.errors }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/notification_preferences/subscribe_push
      def subscribe_push
        subscription_data = JSON.parse(params[:subscription])
        @preference.push_subscription = subscription_data
        
        if @preference.save
          render json: { success: true, message: "Push notifications enabled", preference: @preference }
        else
          render json: { success: false, errors: @preference.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/notification_preferences/unsubscribe_push
      def unsubscribe_push
        @preference.update(
          push_subscription_endpoint: nil,
          push_subscription_keys: nil,
          enable_push_notifications: false
        )
        
        render json: { success: true, message: "Push notifications disabled", preference: @preference }
      end

      private

      def set_preference
        @preference = NotificationPreference.for_user(current_user)
      end

      def preference_params
        params.require(:notification_preference).permit(
          :days_before_expiration,
          :enable_push_notifications,
          :enable_email_notifications
        )
      end
    end
  end
end

