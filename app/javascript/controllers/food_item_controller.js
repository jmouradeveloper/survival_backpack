import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Animação de entrada
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(10px)"
    
    requestAnimationFrame(() => {
      this.element.style.transition = "all 0.3s ease-out"
      this.element.style.opacity = "1"
      this.element.style.transform = "translateY(0)"
    })
  }

  disconnect() {
    // Animação de saída
    this.element.style.transition = "all 0.3s ease-out"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(-10px)"
  }
}

