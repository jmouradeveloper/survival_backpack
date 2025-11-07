import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close(event) {
    if (event.target === this.element) {
      this.element.remove()
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  disconnect() {
    // Limpar modal ao fechar
    this.element.remove()
  }
}

