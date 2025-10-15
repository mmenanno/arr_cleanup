import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="settings-form"
export default class extends Controller {
  connect() {
    // Track initial form state
    this.initialFormData = this.getFormData()
    this.isDirty = false

    // Listen for form changes
    this.element.addEventListener("input", this.markDirty.bind(this))
    this.element.addEventListener("change", this.markDirty.bind(this))

    // Listen for successful form submission
    this.element.addEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))

    // Warn before leaving if there are unsaved changes
    window.addEventListener("beforeunload", this.handleBeforeUnload.bind(this))
  }

  disconnect() {
    window.removeEventListener("beforeunload", this.handleBeforeUnload.bind(this))
  }

  getFormData() {
    const formData = new FormData(this.element)
    return Array.from(formData.entries())
      .map(([key, value]) => `${key}=${value}`)
      .join("&")
  }

  markDirty() {
    const currentFormData = this.getFormData()
    this.isDirty = currentFormData !== this.initialFormData
  }

  handleSubmitEnd(event) {
    // If submission was successful, mark form as clean
    if (event.detail.success) {
      this.isDirty = false
      // Update initial form data to current state
      setTimeout(() => {
        this.initialFormData = this.getFormData()
      }, 100)
    }
  }

  handleBeforeUnload(event) {
    if (this.isDirty) {
      event.preventDefault()
      event.returnValue = ""
      return ""
    }
  }
}

