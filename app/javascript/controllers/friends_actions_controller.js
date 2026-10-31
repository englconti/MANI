import { Controller } from "stimulus"


export default class extends Controller {
  static targets = [ "content", "form", "list", "searchInput" ]

  disconnect() {
    clearTimeout(this.searchTimer)
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

  // Waits for a pause in typing, then searches; shows loading, empty and error states
  update(e) {
    e.preventDefault();
    clearTimeout(this.searchTimer)
    this.searchTimer = setTimeout(() => this.search(), 250)
  }

  async search() {
    const query = this.searchInputTarget.value.trim()
    if (query === "") {
      this.listTarget.innerHTML = ""
      return
    }

    this.listTarget.textContent = "Buscando..."
    const url = `${this.formTarget.action}?query=${encodeURIComponent(query)}`
    try {
      const response = await fetch(url, { headers: { 'Accept': 'text/plain' } })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const data = await response.text()
      // Ignore an answer that arrives after the person kept typing
      if (query !== this.searchInputTarget.value.trim()) return
      if (data.trim() === "") {
        this.listTarget.textContent = "Nenhuma pessoa encontrada."
      } else {
        this.listTarget.innerHTML = data
      }
    } catch (error) {
      this.listTarget.textContent = "Não foi possível buscar agora. Tente de novo."
    }
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
