import { Controller } from "stimulus"


export default class extends Controller {
  static targets = [ "content", "form", "list", "searchInput", "shareStatus" ]

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

  // Shares the address of the app: the phone's share sheet when there is one,
  // otherwise the link is copied
  async share() {
    const data = { title: "Mani", text: "Aprenda finanças jogando com o Mani", url: window.location.origin }
    try {
      if (navigator.share) {
        await navigator.share(data)
        return
      }
      await navigator.clipboard.writeText(data.url)
      this.shareStatusTarget.textContent = "Link copiado! Envie para quem você quer convidar."
    } catch (error) {
      // Closing the share sheet is not an error
      if (error.name === "AbortError") return
      this.shareStatusTarget.textContent = `Copie o link: ${data.url}`
    }
  }
}
