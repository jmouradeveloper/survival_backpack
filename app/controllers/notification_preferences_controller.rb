class NotificationPreferencesController < ApplicationController
  include Authorization
  before_action :set_preference

  # GET /notification_preferences
  def show
    respond_to do |format|
      format.html
      format.json { render json: @preference }
    end
  end

  # GET /notification_preferences/edit
  def edit
  end

  # PATCH/PUT /notification_preferences
  def update
    respond_to do |format|
      if @preference.update(preference_params)
        format.html { redirect_to notification_preferences_path, notice: "Preferências atualizadas com sucesso." }
        format.turbo_stream {
          flash.now[:notice] = "Preferências atualizadas com sucesso."
        }
        format.json { render json: @preference }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
        format.json { render json: @preference.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /notification_preferences/subscribe_push
  def subscribe_push
    subscription_data = params[:subscription].to_unsafe_h
    @preference.push_subscription = subscription_data
    
    if @preference.save
      render json: { success: true, message: "Push notifications habilitadas", preference: @preference }
    else
      render json: { success: false, errors: @preference.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /notification_preferences/unsubscribe_push
  def unsubscribe_push
    @preference.update(
      push_subscription_endpoint: nil,
      push_subscription_keys: nil,
      enable_push_notifications: false
    )
    
    render json: { success: true, message: "Push notifications desabilitadas" }
  end

  # POST /notification_preferences/test_notification
  def test_notification
    # Criar uma notificação de teste
    food_item = current_user.food_items.first
    
    if food_item
      notification = current_user.notifications.create!(
        food_item: food_item,
        title: "🧪 Notificação de Teste",
        body: "Esta é uma notificação de teste do sistema de alertas.",
        notification_type: "expiration_warning",
        priority: 1
      )
      
      notification.send_notification!
      
      respond_to do |format|
        format.html { redirect_to notification_preferences_path, notice: "✅ Notificação de teste criada com sucesso! Verifique a página de Notificações." }
        format.json { render json: { success: true, notification: notification } }
      end
    else
      respond_to do |format|
        format.html { redirect_to notification_preferences_path, alert: "❌ Nenhum alimento cadastrado para teste. Cadastre um alimento primeiro." }
        format.json { render json: { success: false, message: "Nenhum alimento cadastrado para teste" }, status: :unprocessable_entity }
      end
    end
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

