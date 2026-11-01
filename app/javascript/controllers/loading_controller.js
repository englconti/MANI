import { Controller } from "stimulus"

// The "loading" screen. It appears only if changing page takes longer than the delay, so fast
// navigations (like on a developer's machine) never flash it. The Turbo events that start and
// end a visit are wired in the partial (shared/_loading).
export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } }

  disconnect() {
    clearTimeout(this.timer)
  }

  schedule() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => { this.element.hidden = false }, this.delayValue)
  }

  hide() {
    clearTimeout(this.timer)
    this.element.hidden = true
  }
}
