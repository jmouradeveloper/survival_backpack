import { Controller } from "@hotwired/stimulus"

// Conecta ao data-controller="notifications"
export default class extends Controller {
  static targets = ["badge", "list", "permission", "browserPermission", "permissionAction", "pushStatus", "pushAction"]
  static values = {
    refreshInterval: { type: Number, default: 60000 }, // 1 minuto
    checkPermission: { type: Boolean, default: true }
  }

  connect() {
    console.log("Notifications controller connected")
    
    if (this.checkPermissionValue) {
      this.checkNotificationPermission()
    }
    
    // Verificar status do navegador se elemento existe
    if (this.hasBrowserPermissionTarget) {
      this.updateBrowserPermissionStatus()
    }
    
    this.startPolling()
    this.updateUnreadCount()
    this.registerServiceWorker()
  }

  disconnect() {
    this.stopPolling()
  }

  async checkNotificationPermission() {
    if (!("Notification" in window)) {
      console.log("Este navegador não suporta notificações")
      return
    }

    if (Notification.permission === "default" && this.hasPermissionTarget) {
      this.permissionTarget.classList.remove("hidden")
    }
  }

  async requestPermission(event) {
    event.preventDefault()
    
    if (!('Notification' in window)) {
      alert("❌ Este navegador não suporta notificações.")
      return
    }

    try {
      const permission = await Notification.requestPermission()
      
      // Atualizar status na interface
      this.updateBrowserPermissionStatus()
      
      if (permission === "granted") {
        console.log("Permissão de notificação concedida")
        
        // Registrar para push notifications
        await this.subscribeToPush()
        
        // Mostrar notificação de confirmação
        this.showTestNotification()
        
        // Mostrar mensagem de sucesso
        alert("✅ Permissões concedidas com sucesso!\n\nAgora você receberá notificações sobre a validade dos seus alimentos.")
      } else if (permission === "denied") {
        alert("❌ Permissão negada.\n\nPara ativar as notificações, você precisará alterar as configurações do navegador manualmente.")
      } else {
        alert("⚠️ Permissão não concedida.\n\nVocê pode tentar novamente quando desejar receber notificações.")
      }
    } catch (error) {
      console.error("Erro ao solicitar permissão:", error)
      alert("❌ Erro ao solicitar permissão. Tente novamente.")
    }
  }

  async registerServiceWorker() {
    if (!("serviceWorker" in navigator)) {
      console.log("Service Worker não suportado")
      return
    }

    try {
      const registration = await navigator.serviceWorker.ready
      console.log("Service Worker registrado:", registration)
      
      // Registrar periodic background sync (se suportado)
      if ("periodicSync" in registration) {
        try {
          await registration.periodicSync.register("check-expirations", {
            minInterval: 24 * 60 * 60 * 1000, // 24 horas
          })
          console.log("Periodic sync registrado")
        } catch (error) {
          console.log("Periodic sync não disponível:", error)
        }
      }
    } catch (error) {
      console.error("Erro ao registrar service worker:", error)
    }
  }

  async subscribeToPush() {
    try {
      const registration = await navigator.serviceWorker.ready
      
      // Verificar se já tem subscription
      let subscription = await registration.pushManager.getSubscription()
      
      if (!subscription) {
        // Criar nova subscription
        // Nota: Em produção, você precisaria gerar as VAPID keys
        // e configurá-las no servidor
        const vapidPublicKey = this.getVapidPublicKey()
        
        if (vapidPublicKey) {
          subscription = await registration.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: this.urlBase64ToUint8Array(vapidPublicKey)
          })
          
          // Enviar subscription para o servidor
          await this.sendSubscriptionToServer(subscription)
        }
      }
      
      return subscription
    } catch (error) {
      console.error("Erro ao inscrever em push notifications:", error)
    }
  }

  async sendSubscriptionToServer(subscription) {
    try {
      const response = await fetch("/notification_preferences/subscribe_push", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.getCSRFToken()
        },
        body: JSON.stringify({ subscription: subscription.toJSON() })
      })
      
      if (response.ok) {
        console.log("Subscription enviada ao servidor")
      }
    } catch (error) {
      console.error("Erro ao enviar subscription:", error)
    }
  }

  showTestNotification() {
    if (Notification.permission === "granted") {
      new Notification("✅ Notificações Ativadas!", {
        body: "Você receberá alertas sobre a validade dos seus alimentos.",
        icon: "/icon.png",
        badge: "/icon.png"
      })
    }
  }

  startPolling() {
    this.pollInterval = setInterval(() => {
      this.updateUnreadCount()
    }, this.refreshIntervalValue)
  }

  stopPolling() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
    }
  }

  async updateUnreadCount() {
    try {
      const response = await fetch("/notifications/unread_count")
      if (response.ok) {
        const data = await response.json()
        this.updateBadge(data.count)
      }
    } catch (error) {
      console.error("Erro ao atualizar contador:", error)
    }
  }

  updateBadge(count) {
    if (this.hasBadgeTarget) {
      this.badgeTarget.textContent = count
      
      if (count > 0) {
        this.badgeTarget.classList.remove("hidden")
      } else {
        this.badgeTarget.classList.add("hidden")
      }
    }
  }

  async markAsRead(event) {
    event.preventDefault()
    
    const notificationId = event.currentTarget.dataset.notificationId
    if (!notificationId) return
    
    try {
      const response = await fetch(`/notifications/${notificationId}/mark_as_read`, {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          "Accept": "application/json"
        }
      })
      
      if (response.ok) {
        // Atualizar interface
        const notificationElement = event.currentTarget.closest(".notification-item")
        if (notificationElement) {
          notificationElement.classList.remove("unread")
          notificationElement.classList.add("read")
        }
        
        this.updateUnreadCount()
      }
    } catch (error) {
      console.error("Erro ao marcar como lida:", error)
    }
  }

  async markAllAsRead(event) {
    event.preventDefault()
    
    try {
      const response = await fetch("/notifications/mark_all_as_read", {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          "Accept": "application/json"
        }
      })
      
      if (response.ok) {
        // Atualizar interface
        const unreadItems = this.element.querySelectorAll(".notification-item.unread")
        unreadItems.forEach(item => {
          item.classList.remove("unread")
          item.classList.add("read")
        })
        
        this.updateUnreadCount()
      }
    } catch (error) {
      console.error("Erro ao marcar todas como lidas:", error)
    }
  }

  async triggerBackgroundSync() {
    try {
      const registration = await navigator.serviceWorker.ready
      await registration.sync.register("check-expirations")
      console.log("Background sync acionado")
    } catch (error) {
      console.error("Erro ao acionar background sync:", error)
    }
  }

  async testNotification(event) {
    event.preventDefault()
    
    try {
      const response = await fetch("/notification_preferences/test_notification", {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          "Accept": "application/json"
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        console.log("Notificação de teste criada:", data)
        
        // Mostrar notificação do navegador se permitido
        if (Notification.permission === "granted") {
          new Notification("🧪 Notificação de Teste", {
            body: "O sistema de notificações está funcionando corretamente!",
            icon: "/icon.png",
            badge: "/icon.png"
          })
        }
        
        // Atualizar contador
        this.updateUnreadCount()
      }
    } catch (error) {
      console.error("Erro ao testar notificação:", error)
    }
  }

  updateBrowserPermissionStatus() {
    if (!this.hasBrowserPermissionTarget) return
    
    const element = this.browserPermissionTarget
    const actionElement = this.hasPermissionActionTarget ? this.permissionActionTarget : null
    
    if (!('Notification' in window)) {
      element.textContent = '❌ Não suportado'
      element.style.color = '#dc3545'
      if (actionElement) actionElement.style.display = 'none'
    } else {
      const permission = Notification.permission
      if (permission === 'granted') {
        element.textContent = '✅ Concedida'
        element.style.color = '#28a745'
        if (actionElement) actionElement.style.display = 'none'
      } else if (permission === 'denied') {
        element.textContent = '❌ Negada'
        element.style.color = '#dc3545'
        if (actionElement) {
          actionElement.style.display = 'flex'
          actionElement.querySelector('button').textContent = '⚙️ Ver Instruções para Reativar'
          actionElement.querySelector('button').onclick = () => {
            alert("📋 Como reativar notificações:\n\n" +
                  "1. Clique no ícone de cadeado/info na barra de endereços\n" +
                  "2. Procure por 'Notificações'\n" +
                  "3. Mude de 'Bloquear' para 'Permitir'\n" +
                  "4. Recarregue a página")
          }
        }
      } else {
        element.textContent = '⚠️ Não solicitada'
        element.style.color = '#ff9800'
        if (actionElement) actionElement.style.display = 'flex'
      }
    }
  }

  async enablePushNotifications(event) {
    event.preventDefault()
    
    // Verificar se notificações são suportadas
    if (!('Notification' in window)) {
      alert("❌ Este navegador não suporta notificações push.")
      return
    }

    // Verificar se já tem permissão, se não, solicitar
    if (Notification.permission === 'default') {
      const permission = await Notification.requestPermission()
      this.updateBrowserPermissionStatus()
      
      if (permission !== 'granted') {
        alert("❌ Permissão de notificação necessária.\n\nSem a permissão, não é possível ativar push notifications.")
        return
      }
    } else if (Notification.permission === 'denied') {
      alert("❌ Permissão de notificação negada.\n\nVocê precisa alterar as configurações do navegador manualmente para ativar as notificações.")
      return
    }

    // Mostrar loading
    const button = event.currentTarget
    const originalText = button.innerHTML
    button.innerHTML = '⏳ Ativando...'
    button.disabled = true

    try {
      // Registrar Service Worker e obter subscription
      const registration = await navigator.serviceWorker.ready
      
      // Verificar se já tem subscription
      let subscription = await registration.pushManager.getSubscription()
      
      if (!subscription) {
        // Criar nova subscription
        // Nota: Em produção, você precisaria de VAPID keys reais
        const vapidPublicKey = this.getVapidPublicKey()
        
        if (vapidPublicKey) {
          subscription = await registration.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: this.urlBase64ToUint8Array(vapidPublicKey)
          })
        } else {
          // Se não tem VAPID key, criar subscription básica
          subscription = await registration.pushManager.subscribe({
            userVisibleOnly: true
          })
        }
      }

      // Enviar subscription para o servidor
      const response = await fetch("/notification_preferences/subscribe_push", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.getCSRFToken()
        },
        body: JSON.stringify({ subscription: subscription.toJSON() })
      })

      if (response.ok) {
        // Atualizar interface
        if (this.hasPushStatusTarget) {
          this.pushStatusTarget.textContent = '✅ Ativas'
          this.pushStatusTarget.style.color = '#28a745'
        }
        
        if (this.hasPushActionTarget) {
          this.pushActionTarget.style.display = 'none'
        }

        // Mostrar notificação de sucesso
        new Notification("✅ Push Notifications Ativadas!", {
          body: "Você agora receberá alertas sobre a validade dos seus alimentos, mesmo quando o app estiver fechado.",
          icon: "/icon.png",
          badge: "/icon.png"
        })

        alert("✅ Push Notifications ativadas com sucesso!\n\n" +
              "Você agora receberá alertas sobre a validade dos seus alimentos, " +
              "mesmo quando o navegador estiver fechado.\n\n" +
              "Funciona até mesmo offline!")
        
        // Recarregar página para atualizar status
        window.location.reload()
      } else {
        const data = await response.json()
        throw new Error(data.message || 'Erro ao ativar push notifications')
      }
    } catch (error) {
      console.error("Erro ao ativar push notifications:", error)
      alert("❌ Erro ao ativar push notifications:\n\n" + error.message + "\n\nTente novamente.")
      
      // Restaurar botão
      button.innerHTML = originalText
      button.disabled = false
    }
  }

  // Helper methods
  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }

  getVapidPublicKey() {
    const meta = document.querySelector('meta[name="vapid-public-key"]')
    return meta ? meta.content : null
  }

  urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding)
      .replace(/\-/g, "+")
      .replace(/_/g, "/")

    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }
}

