import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["checkbox", "switch"]

  toggle() {
    this.checkboxTarget.checked = !this.checkboxTarget.checked
    this.updateSwitch()

    // Trigger change event
    this.checkboxTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  updateSwitch() {
    const isChecked = this.checkboxTarget.checked

    if (this.hasSwitchTarget) {
      const circle = this.switchTarget.querySelector("span:last-child")

      if (isChecked) {
        this.switchTarget.classList.add("bg-indigo-600")
        this.switchTarget.classList.remove("bg-gray-700")
        circle.classList.add("translate-x-5")
        circle.classList.remove("translate-x-0")
      } else {
        this.switchTarget.classList.remove("bg-indigo-600")
        this.switchTarget.classList.add("bg-gray-700")
        circle.classList.remove("translate-x-5")
        circle.classList.add("translate-x-0")
      }
    }
  }

  connect() {
    this.updateSwitch()
  }
}

