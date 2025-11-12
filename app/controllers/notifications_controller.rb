class NotificationsController < ApplicationController
  include Authorization
  before_action :set_notification, only: [:show, :mark_as_read, :destroy]

  # GET /notifications
  def index
    @notifications = current_user.notifications.includes(:food_item).recent.limit(50)
    @unread_count = current_user.notifications.unread.count

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /notifications/:id
  def show
    @notification.mark_as_read! unless @notification.read?

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # POST /notifications/:id/mark_as_read
  def mark_as_read
    @notification.mark_as_read!

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "Notificação marcada como lida." }
      format.turbo_stream {
        flash.now[:notice] = "Notificação marcada como lida."
      }
      format.json { render json: @notification }
    end
  end

  # POST /notifications/mark_all_as_read
  def mark_all_as_read
    current_user.notifications.unread.update_all(read: true)

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "Todas as notificações foram marcadas como lidas." }
      format.turbo_stream {
        flash.now[:notice] = "Todas as notificações foram marcadas como lidas."
      }
      format.json { head :ok }
    end
  end

  # DELETE /notifications/:id
  def destroy
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: "Notificação removida." }
      format.turbo_stream {
        flash.now[:notice] = "Notificação removida."
      }
      format.json { head :no_content }
    end
  end

  # GET /notifications/unread_count
  def unread_count
    count = current_user.notifications.unread.count
    render json: { count: count }
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end

