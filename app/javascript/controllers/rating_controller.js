import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "message"]

  async submit(event) {
    event.preventDefault()

    const formData = new FormData(this.formTarget)
    const csrfToken = document.querySelector("[name='csrf-token']")?.content

    try {
      const response = await fetch(this.formTarget.action, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: new URLSearchParams(formData)
      })

      const data = await response.json()

      if (response.ok && data.success) {
        this.messageTarget.textContent = data.message
        this.messageTarget.className = "mt-2 text-green-600"
      } else {
        this.messageTarget.textContent = data.errors.join(", ")
        this.messageTarget.className = "mt-2 text-red-600"
      }
    } catch (error) {
      this.messageTarget.textContent = "Something went wrong. Please try again."
      this.messageTarget.className = "mt-2 text-red-600"
    }
  }
}
