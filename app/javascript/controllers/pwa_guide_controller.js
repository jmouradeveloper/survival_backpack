import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "dontShowAgain"]

  connect() {
    // Check if service worker is ready and if we should show the guide
    this.checkServiceWorkerStatus()
  }

  async checkServiceWorkerStatus() {
    if (!('serviceWorker' in navigator)) {
      return
    }

    try {
      const registration = await navigator.serviceWorker.ready
      
      // Check if service worker is activated
      if (registration.active) {
        // Check if user has already seen the guide
        const hasSeenGuide = localStorage.getItem('pwa-guide-seen')
        
        if (!hasSeenGuide) {
          // Wait a bit before showing the modal to ensure page is loaded
          setTimeout(() => {
            this.showModal()
          }, 2000)
        }
      }
    } catch (error) {
      console.log('Service Worker not ready:', error)
    }
  }

  showModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove('hidden')
      document.body.style.overflow = 'hidden'
    }
  }

  show(event) {
    if (event) {
      event.preventDefault()
    }
    this.showModal()
  }

  hideModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add('hidden')
      document.body.style.overflow = ''
    }
  }

  close(event) {
    // Close if clicking on overlay
    if (event.target === this.modalTarget) {
      this.dismiss()
    }
  }

  dismiss(event) {
    if (event) {
      event.preventDefault()
    }

    // Check if "don't show again" is checked
    if (this.hasDontShowAgainTarget && this.dontShowAgainTarget.checked) {
      localStorage.setItem('pwa-guide-seen', 'true')
    }

    this.hideModal()
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  switchTab(event) {
    event.preventDefault()
    const tabName = event.currentTarget.dataset.tab

    // Update active tab button
    this.element.querySelectorAll('[data-tab]').forEach(button => {
      button.classList.remove('active')
    })
    event.currentTarget.classList.add('active')

    // Update visible content
    this.element.querySelectorAll('[data-tab-content]').forEach(content => {
      if (content.dataset.tabContent === tabName) {
        content.classList.remove('hidden')
      } else {
        content.classList.add('hidden')
      }
    })
  }

  // Method to reset the guide (useful for testing)
  reset() {
    localStorage.removeItem('pwa-guide-seen')
    console.log('PWA guide reset - will show again on next page load')
  }
}

