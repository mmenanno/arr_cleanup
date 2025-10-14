import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-submit"
export default class extends Controller {
  submit(event) {
    event.target.form.requestSubmit()
  }

  submitTo(event) {
    event.preventDefault()
    const button = event.currentTarget
    const url = button.dataset.url
    if (!url) return

    // Get form data from closest form
    const form = button.closest('form')
    let body = null

    if (form) {
      const formData = new FormData(form)
      // Convert FormData to URLSearchParams for proper Rails params parsing
      body = new URLSearchParams(formData)
    }

    fetch(url, {
      method: 'POST',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: body
    }).then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.text()
    })
      .then(html => Turbo.renderStreamMessage(html))
      .catch(error => console.error('Error:', error))
  }
}

