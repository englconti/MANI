import { Controller } from "stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Counts down to a moment (ISO 8601) and reloads the page when it arrives,
// so the server can give the life back.
export default class extends Controller {
  static targets = ["display"]
  static values = { until: String }

  connect() {
    this.tick()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const remaining = Math.max(0, Math.round((new Date(this.untilValue) - new Date()) / 1000))
    const minutes = String(Math.floor(remaining / 60)).padStart(2, "0")
    const seconds = String(remaining % 60).padStart(2, "0")
    this.displayTarget.textContent = `${minutes}:${seconds}`

    if (remaining === 0) {
      clearInterval(this.timer)
      Turbo.visit(window.location.href, { action: "replace" })
    }
  }
}
