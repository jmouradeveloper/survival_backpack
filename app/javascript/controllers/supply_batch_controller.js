import { Controller } from "@hotwired/stimulus"

// Conecta ao data-controller="supply-batch"
export default class extends Controller {
  static targets = ["consumeModal", "quantity", "rotationType", "reason", "notes"]
  
  connect() {
    console.log("Supply batch controller connected")
  }
  
  showConsumeModal(event) {
    event.preventDefault()
    const batchId = event.currentTarget.dataset.batchId
    const maxQuantity = parseFloat(event.currentTarget.dataset.maxQuantity)
    
    // Cria modal dinamicamente
    const modal = this.createConsumeModal(batchId, maxQuantity)
    document.body.appendChild(modal)
    
    // Foca no campo de quantidade
    setTimeout(() => {
      const quantityInput = modal.querySelector('input[name="quantity"]')
      if (quantityInput) quantityInput.focus()
    }, 100)
  }
  
  createConsumeModal(batchId, maxQuantity) {
    const modalDiv = document.createElement('div')
    modalDiv.id = 'consume-modal'
    modalDiv.className = 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50'
    modalDiv.dataset.controller = "modal"
    modalDiv.dataset.action = "click->modal#close"
    
    modalDiv.innerHTML = `
      <div class="bg-white rounded-lg shadow-xl max-w-md w-full mx-4 p-6" 
           data-modal-target="content"
           data-action="click->modal#preventClose">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-xl font-bold text-gray-800">Registrar Consumo</h3>
          <button type="button" 
                  class="text-gray-500 hover:text-gray-700 text-2xl font-bold"
                  data-action="click->modal#close">×</button>
        </div>
        
        <form action="/supply_batches/${batchId}/consume" method="post" data-turbo="true">
          <input type="hidden" name="authenticity_token" value="${this.getCSRFToken()}">
          
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Quantidade *
              </label>
              <input type="number" 
                     name="quantity" 
                     step="0.01" 
                     min="0.01" 
                     max="${maxQuantity}"
                     required
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                     placeholder="Ex: 1.5">
              <p class="text-xs text-gray-500 mt-1">Máximo disponível: ${maxQuantity}</p>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Tipo de Rotação *
              </label>
              <select name="rotation_type" 
                      required
                      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                <option value="consumption">Consumo</option>
                <option value="waste">Descarte/Perda</option>
                <option value="donation">Doação</option>
                <option value="transfer">Transferência</option>
              </select>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Motivo
              </label>
              <input type="text" 
                     name="reason" 
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                     placeholder="Ex: Uso diário, vencido, etc.">
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Observações
              </label>
              <textarea name="notes" 
                        rows="2"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        placeholder="Informações adicionais..."></textarea>
            </div>
          </div>
          
          <div class="flex gap-3 mt-6">
            <button type="submit"
                    class="flex-1 bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded transition">
              Confirmar Consumo
            </button>
            <button type="button"
                    data-action="click->modal#close"
                    class="flex-1 bg-gray-200 hover:bg-gray-300 text-gray-700 font-semibold py-2 px-4 rounded transition">
              Cancelar
            </button>
          </div>
        </form>
      </div>
    `
    
    return modalDiv
  }
  
  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute('content') : ''
  }
  
  closeModal() {
    const modal = document.getElementById('consume-modal')
    if (modal) {
      modal.remove()
    }
  }
}

