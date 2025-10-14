import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["container"]

  show(event) {
    event.preventDefault()
    event.stopPropagation() // Prevent parent link from triggering
    console.log("Modal show triggered", event.currentTarget.dataset)

    const message = event.currentTarget.dataset.confirmMessage || "Are you sure?"
    const url = event.currentTarget.dataset.confirmUrl
    const method = event.currentTarget.dataset.confirmMethod || "post"

    console.log("Modal data:", { message, url, method })

    if (!url) {
      console.error("No URL provided for modal")
      return
    }

    this.containerTarget.querySelector("[data-modal-message]").textContent = message
    this.containerTarget.querySelector("[data-modal-confirm]").dataset.url = url
    this.containerTarget.querySelector("[data-modal-confirm]").dataset.method = method

    this.containerTarget.classList.remove("hidden")
  }

  hide() {
    this.containerTarget.classList.add("hidden")
  }

  confirm(event) {
    event.preventDefault()
    const button = event.currentTarget
    const url = button.dataset.url
    const method = button.dataset.method || "post"

    // Use fetch for Turbo Stream support
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    fetch(url, {
      method: method.toUpperCase(),
      headers: {
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html, text/html, application/xhtml+xml"
      },
      credentials: "same-origin"
    }).then(response => {
      if (response.ok) {
        return response.text()
      } else {
        throw new Error("Request failed")
      }
    }).then(html => {
      // Let Turbo handle the stream response
      if (html.includes("<turbo-stream")) {
        Turbo.renderStreamMessage(html)
      } else {
        // Fallback to page reload if not a turbo stream
        window.location.reload()
      }
    }).catch(error => {
      console.error("Error:", error)
      alert("Failed to perform action")
    })

    this.hide()
  }
}

