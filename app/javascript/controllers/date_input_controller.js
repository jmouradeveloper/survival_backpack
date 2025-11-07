import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  format(event) {
    let value = event.target.value.replace(/\D/g, '')
    
    // Limitar a 8 dígitos
    if (value.length > 8) {
      value = value.slice(0, 8)
    }
    
    // Formatar como DD/MM/AAAA
    if (value.length >= 5) {
      value = value.slice(0, 2) + '/' + value.slice(2, 4) + '/' + value.slice(4)
    } else if (value.length >= 3) {
      value = value.slice(0, 2) + '/' + value.slice(2)
    }
    
    event.target.value = value
  }

  connect() {
    // Garantir que o valor inicial esteja formatado
    if (this.element.value && !this.element.value.includes('/')) {
      const fakeEvent = { target: this.element }
      this.format(fakeEvent)
    }
  }
}

