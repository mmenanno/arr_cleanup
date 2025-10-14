import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="debounce"
export default class extends Controller {
  static targets = ["form"]

  search(event) {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      event.target.form.requestSubmit()
    }, 300)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}

