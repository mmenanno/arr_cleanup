import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sort-direction"
export default class extends Controller {
  static targets = ["field", "icon"]

  toggle(event) {
    event.preventDefault()

    // Toggle the direction value
    const currentDir = this.fieldTarget.value
    const newDir = currentDir === "asc" ? "desc" : "asc"
    this.fieldTarget.value = newDir

    // Update the icon immediately
    this.updateIcon(newDir)

    // Submit the form
    this.element.closest('form').requestSubmit()
  }

  updateIcon(direction) {
    if (direction === "asc") {
      // Up arrow
      this.iconTarget.innerHTML = `
        <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 10.5L12 3m0 0l7.5 7.5M12 3v18" />
        </svg>
      `
    } else {
      // Down arrow
      this.iconTarget.innerHTML = `
        <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 13.5L12 21m0 0l-7.5-7.5M12 21V3" />
        </svg>
      `
    }
  }
}

