import { Controller } from "stimulus"

export default class extends Controller {

  connect() {
    // console.log(this.contentTarget)
    console.log("Connected:", this.element);
  }

  next(event) {
    event.preventDefault()
    this.element.innerText = "Lets Go!"
  }
}
