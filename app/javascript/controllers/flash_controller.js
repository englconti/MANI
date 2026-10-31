import { Controller } from "stimulus"

// A message at the top of the page. With a delay it closes itself (and waits while the
// pointer or the keyboard focus is on it); without one it stays until it is closed.
export default class extends Controller {
  static values = { delay: Number }

  connect() {
    this.schedule()
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  schedule() {
    clearTimeout(this.timer)
    if (this.delayValue > 0) this.timer = setTimeout(() => this.dismiss(), this.delayValue)
  }

  pause() {
    clearTimeout(this.timer)
  }

  dismiss() {
    clearTimeout(this.timer)
    this.element.remove()
  }
}
