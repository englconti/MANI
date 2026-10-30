import { Controller } from "stimulus"

// "Mostrar senha" checkbox: toggles the password fields between hidden and visible.
export default class extends Controller {
  static targets = ["field"]

  toggle(event) {
    const type = event.currentTarget.checked ? "text" : "password"
    this.fieldTargets.forEach((field) => { field.type = type })
  }
}
