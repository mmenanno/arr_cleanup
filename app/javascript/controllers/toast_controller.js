import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  connect() {
    this.element.classList.add("animate-slide-in")

    // Auto-dismiss after 5 seconds
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.classList.remove("animate-slide-in")
    this.element.classList.add("animate-slide-out")

    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}

