import { Controller } from "stimulus"

// Asks for confirmation inside the app before an avatar is bought. Every buy form of the page
// carries the avatar's data; submitting one opens the dialog, and only "Comprar" sends it. Without
// JavaScript the forms still work, they just buy straight away.
export default class extends Controller {
  static targets = ["dialog", "image", "name", "tier", "price", "balance", "after", "confirm"]
  static values = { balance: Number }

  ask(event) {
    const form = event.currentTarget
    if (this.confirmedForm === form) {
      this.confirmedForm = null
      return
    }

    event.preventDefault()
    this.form = form
    const { avatarName, avatarTier, avatarImage, avatarPrice } = form.dataset
    const price = Number(avatarPrice)

    this.imageTarget.src = avatarImage
    this.imageTarget.alt = ""
    this.nameTarget.textContent = avatarName
    this.tierTarget.textContent = avatarTier
    this.priceTarget.textContent = `${price} M$`
    this.balanceTarget.textContent = `${this.balanceValue} M$`
    this.afterTarget.textContent = `${this.balanceValue - price} M$`
    this.dialogTarget.showModal()
  }

  confirm() {
    const form = this.form
    this.close()
    if (!form) return

    this.confirmedForm = form
    form.requestSubmit()
  }

  close() {
    if (this.dialogTarget.open) this.dialogTarget.close()
  }

  // A click on the dark backdrop (the dialog element itself) closes it too
  backdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }
}
