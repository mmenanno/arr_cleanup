import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="test-connection"
export default class extends Controller {
  static values = {
    url: String,
    urlField: String,
    keyField: String,
    service: String
  }

  test(event) {
    event.preventDefault()

    // Get current values from form fields
    const urlInput = document.getElementById(this.urlFieldValue)
    const keyInput = document.getElementById(this.keyFieldValue)

    const url = urlInput ? urlInput.value : ""
    const key = keyInput ? keyInput.value : ""

    // Determine field names based on service
    const serviceType = this.urlFieldValue.includes('radarr') ? 'radarr' : 'sonarr'

    // Build form data
    const formData = new URLSearchParams()
    formData.append(`app_setting[${serviceType}_url]`, url)
    formData.append(`app_setting[${serviceType}_api_key]`, key)

    // Submit
    fetch(this.urlValue, {
      method: 'POST',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: formData
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
      .catch(error => console.error('Error testing connection:', error))
  }
}

