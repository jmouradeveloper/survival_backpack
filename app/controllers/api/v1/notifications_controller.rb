module Api
  module V1
    class NotificationsController < Api::V1::BaseController
      before_action :set_notification, only: [:show, :mark_as_read, :destroy]

      # GET /api/v1/notifications
      def index
        @notifications = current_user.notifications.includes(:food_item).recent
        
        # Filtros opcionais
        @notifications = @notifications.unread if params[:unread] == 'true'
        @notifications = @notifications.by_type(params[:type]) if params[:type].present?
        
        # Paginação
        page = params[:page]&.to_i || 1
        per_page = params[:per_page]&.to_i || 20
        per_page = 100 if per_page > 100 # Limite máximo
        
        @notifications = @notifications.limit(per_page).offset((page - 1) * per_page)
        
        render json: {
          notifications: @notifications,
          meta: {
            page: page,
            per_page: per_page,
            total: current_user.notifications.count,
            unread_count: current_user.notifications.unread.count
          }
        }
      end

      # GET /api/v1/notifications/:id
      def show
        @notification.mark_as_read! unless @notification.read?
        render json: @notification
      end

      # POST /api/v1/notifications/:id/mark_as_read
      def mark_as_read
        @notification.mark_as_read!
        render json: @notification
      end

      # POST /api/v1/notifications/mark_all_as_read
      def mark_all_as_read
        current_user.notifications.unread.update_all(read: true)
        render json: { message: "All notifications marked as read" }
      end

      # DELETE /api/v1/notifications/:id
      def destroy
        @notification.destroy
        head :no_content
      end

      # GET /api/v1/notifications/unread_count
      def unread_count
        count = current_user.notifications.unread.count
        render json: { count: count }
      end

      private

      def set_notification
        @notification = current_user.notifications.find(params[:id])
      end
    end
  end
end

