import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    // Encontrar o formulário dentro do elemento
    const form = this.element.querySelector('form')
    
    if (!form) {
      console.error('Formulário não encontrado dentro do elemento filters')
      return
    }
    
    // Submit automático do form quando um filtro muda
    if (form.requestSubmit) {
      // Navegadores modernos - mantém validação HTML5
      form.requestSubmit()
    } else {
      // Fallback para navegadores mais antigos
      form.submit()
    }
  }
}

