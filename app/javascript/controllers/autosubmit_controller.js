import { Controller } from "stimulus"

// Sends the form again when a field changes, so the result follows the choices. Typing waits for
// a pause first. The submit button stays for anyone who prefers it (and for no JavaScript).
export default class extends Controller {
  disconnect() {
    clearTimeout(this.timer)
  }

  submit() {
    clearTimeout(this.timer)
    this.element.requestSubmit()
  }

  debounce(event) {
    // Checkboxes and the select fire "change" as well; only text typing needs the wait
    if (event.target.type !== "text") return
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.element.requestSubmit(), 600)
  }
}
