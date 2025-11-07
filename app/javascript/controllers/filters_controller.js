import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    // Submit automático do form quando um filtro muda
    this.element.requestSubmit()
  }
}

