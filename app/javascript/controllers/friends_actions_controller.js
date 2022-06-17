import { Controller } from "stimulus"


export default class extends Controller {
  static targets = [ "content", "form", "list", "searchInput" ]

  connect() {
    console.log("Connected:", this.element);
  }

  openWindow(e) {
    // e.preventDefault();
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

  update(e) {
    e.preventDefault();
    console.log("teste");
    const url = `${this.formTarget.action}?query=${this.searchInputTarget.value}`
    fetch(url, { headers: { 'Accept': 'text/plain' } })
      .then(response => response.text())
      .then((data) => {
        console.log(data);
        this.listTarget.innerHTML = data;
      })
  }

  openInviteWindow(e) {
    // e.preventDefault();
    const overlay = document.querySelector(".overlay-send-invite");
    const windowAddFriend = document.querySelector(".box-window-send-invite");

    overlay.classList.remove("hidden");
    windowAddFriend.classList.remove("hidden");
  }

  closeInviteWindow() {
    const overlay = document.querySelector(".overlay-send-invite");
    const windowSendInvite = document.querySelector(".box-window-send-invite");

    overlay.classList.add("hidden");
    windowSendInvite.classList.add("hidden");
  }

  sendInviteFake() {
    document.querySelector("#blank-space-send-invite").hidden = true;
    document.querySelector("#fake-invite-msg").hidden = false;
  }
}
