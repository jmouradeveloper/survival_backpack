import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Aguardar o Flatpickr estar disponível
    if (typeof flatpickr === 'undefined') {
      setTimeout(() => this.connect(), 100)
      return
    }

    // Inicializar Flatpickr
    flatpickr(this.element, {
      locale: "pt",
      dateFormat: "d/m/Y",
      altInput: false,
      allowInput: false,
      minDate: "today",
      disableMobile: true, // Força usar o calendário customizado em mobile
      onChange: (selectedDates, dateStr, instance) => {
        // Disparar evento de change para que o Turbo detecte mudanças
        this.element.dispatchEvent(new Event('change', { bubbles: true }))
      },
      // Posicionar o calendário
      position: "auto",
      // Permitir limpar a data
      allowClear: true
    })
  }

  disconnect() {
    // Destruir a instância do Flatpickr ao sair
    if (this.element._flatpickr) {
      this.element._flatpickr.destroy()
    }
  }
}

