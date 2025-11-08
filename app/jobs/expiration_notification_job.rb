class ExpirationNotificationJob < ApplicationJob
  queue_as :default

  def perform
    preferences = NotificationPreference.current
    days_before = preferences.days_before_expiration

    # Atualizar o timestamp de última verificação
    preferences.update(last_checked_at: Time.current)

    # Encontrar alimentos que estão perto de vencer
    food_items_expiring = FoodItem
      .where("expiration_date IS NOT NULL")
      .where("expiration_date <= ?", Date.today + days_before.days)
      .where("expiration_date >= ?", Date.today)

    # Encontrar alimentos já vencidos
    food_items_expired = FoodItem.expired

    # Criar notificações para itens que estão vencendo
    food_items_expiring.find_each do |food_item|
      create_expiration_warning(food_item, days_before)
    end

    # Criar notificações para itens vencidos
    food_items_expired.find_each do |food_item|
      create_expired_notification(food_item)
    end

    # Enviar notificações pendentes
    send_pending_notifications(preferences)
  end

  private

  def create_expiration_warning(food_item, days_before)
    days_remaining = food_item.days_until_expiration

    # Não criar notificação duplicada se já existir uma recente (últimas 24 horas)
    return if food_item.notifications
      .where(notification_type: 'expiration_warning')
      .where('created_at > ?', 24.hours.ago)
      .exists?

    # Determinar prioridade baseada nos dias restantes
    priority = calculate_priority(days_remaining, days_before)

    notification = food_item.notifications.create!(
      title: notification_title(food_item, days_remaining),
      body: notification_body(food_item, days_remaining),
      notification_type: days_remaining <= 2 ? 'expiration_urgent' : 'expiration_warning',
      priority: priority,
      scheduled_for: Time.current
    )

    notification
  end

  def create_expired_notification(food_item)
    # Não criar notificação duplicada se já existir uma recente (últimas 24 horas)
    return if food_item.notifications
      .where(notification_type: 'expired')
      .where('created_at > ?', 24.hours.ago)
      .exists?

    days_expired = (Date.today - food_item.expiration_date).to_i

    notification = food_item.notifications.create!(
      title: "⚠️ Alimento Vencido!",
      body: "#{food_item.name} venceu há #{days_expired} dia(s). Verifique e remova se necessário.",
      notification_type: 'expired',
      priority: Notification::PRIORITIES[:high],
      scheduled_for: Time.current
    )

    notification
  end

  def notification_title(food_item, days_remaining)
    if days_remaining == 0
      "🔴 #{food_item.name} vence hoje!"
    elsif days_remaining == 1
      "🟠 #{food_item.name} vence amanhã!"
    elsif days_remaining <= 3
      "🟡 #{food_item.name} vence em #{days_remaining} dias"
    else
      "📅 #{food_item.name} vence em #{days_remaining} dias"
    end
  end

  def notification_body(food_item, days_remaining)
    location = food_item.storage_location.present? ? " (#{food_item.storage_location})" : ""
    expiration_date = I18n.l(food_item.expiration_date, format: :short)
    
    if days_remaining == 0
      "Atenção! Este alimento vence hoje (#{expiration_date})#{location}. Consuma o mais breve possível."
    elsif days_remaining == 1
      "Atenção! Este alimento vence amanhã (#{expiration_date})#{location}. Planeje consumi-lo em breve."
    else
      "Este alimento vence em #{days_remaining} dias (#{expiration_date})#{location}."
    end
  end

  def calculate_priority(days_remaining, days_before)
    if days_remaining == 0
      Notification::PRIORITIES[:high]
    elsif days_remaining <= 2
      Notification::PRIORITIES[:high]
    elsif days_remaining <= (days_before / 2.0)
      Notification::PRIORITIES[:medium]
    else
      Notification::PRIORITIES[:low]
    end
  end

  def send_pending_notifications(preferences)
    return unless preferences.enable_push_notifications

    Notification.pending_to_send.find_each do |notification|
      notification.send_notification!
      
      # Se push notifications estiver habilitado e configurado, enviar
      if preferences.push_notifications_enabled?
        send_push_notification(notification, preferences)
      end
    end
  end

  def send_push_notification(notification, preferences)
    # Aqui você pode integrar com serviços de push como Web Push API
    # Para funcionar offline, as notificações são armazenadas no IndexedDB
    # e o service worker as exibe quando possível
    
    # Por enquanto, apenas broadcasting via Turbo (funciona quando online)
    notification.broadcast_notification
  rescue => e
    Rails.logger.error "Erro ao enviar push notification: #{e.message}"
  end
end

