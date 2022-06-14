import { Controller } from "stimulus"


export default class extends Controller {
  static targets = [ "content" ]

  connect() {
    console.log("Connected:", this.element);
  }

  openWindow() {
    const overlay = document.querySelector(".overlay");
    const windowAddFriend = document.querySelector(".box-window-add-friend");

    overlay.classList.remove("hidden");
    windowAddFriend.classList.remove("hidden");
  }

  closeWindow() {
    const overlay = document.querySelector(".overlay");
    const windowAddFriend = document.querySelector(".box-window-add-friend");

    overlay.classList.add("hidden");
    windowAddFriend.classList.add("hidden");
  }

}
