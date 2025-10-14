import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["button", "menu", "input"]
  static values = {
    selected: String
  }

  connect() {
    this.close = this.close.bind(this)
  }

  toggle(event) {
    event.preventDefault()
    this.menuTarget.classList.toggle("hidden")

    if (!this.menuTarget.classList.contains("hidden")) {
      document.addEventListener("click", this.close)
    }
  }

  select(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.value
    const label = event.currentTarget.textContent.trim()

    this.selectedValue = value
    this.buttonTarget.querySelector("span").textContent = label
    this.inputTarget.value = value

    // Trigger change event to submit form
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))

    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.close)
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
      document.removeEventListener("click", this.close)
    }
  }

  disconnect() {
    document.removeEventListener("click", this.close)
  }
}

