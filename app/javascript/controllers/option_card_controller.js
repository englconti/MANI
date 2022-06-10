import { Controller } from "stimulus"


export default class extends Controller {
  static targets = [ "content" ]

  connect() {
    console.log("Connected:", this.element);
  }

  markCard(e) {
    e.preventDefault();

    const cardA = document.querySelector('.questionA');
    const cardB = document.querySelector('.questionB');
    const cardC = document.querySelector('.questionC');
    const cardD = document.querySelector('.questionD');

    const clickedCardValue = e.currentTarget.children[0].children[0].textContent;

    if (clickedCardValue == "A") {
      cardA.classList.toggle('marked');
      if (cardB.classList.contains('marked')) {
        cardB.classList.remove('marked');
      }
      if (cardC.classList.contains('marked')) {
        cardC.classList.remove('marked');
      }
      if (cardD.classList.contains('marked')) {
        cardD.classList.remove('marked');
      }
    }
    if (clickedCardValue == "B") {
      cardB.classList.toggle('marked');
      if (cardA.classList.contains('marked')) {
        cardA.classList.remove('marked');
      }
      if (cardC.classList.contains('marked')) {
        cardC.classList.remove('marked');
      }
      if (cardD.classList.contains('marked')) {
        cardD.classList.remove('marked');
      }
    }
    if (clickedCardValue == "C") {
      cardC.classList.toggle('marked');
      if (cardA.classList.contains('marked')) {
        cardA.classList.remove('marked');
      }
      if (cardB.classList.contains('marked')) {
        cardB.classList.remove('marked');
      }
      if (cardD.classList.contains('marked')) {
        cardD.classList.remove('marked');
      }
    }
    if (clickedCardValue == "D") {
      cardD.classList.toggle('marked');
      if (cardA.classList.contains('marked')) {
        cardA.classList.remove('marked');
      }
      if (cardB.classList.contains('marked')) {
        cardB.classList.remove('marked');
      }
      if (cardC.classList.contains('marked')) {
        cardC.classList.remove('marked');
      }
    }
    // Feature to enable pressing confirm button only after selecting one option
    const confirmButton = document.getElementById("confirm-button")
    if (document.querySelector('.marked')) {
      confirmButton.removeAttribute("disabled");
    } else {
      confirmButton.disabled = true;
    }
  }
}
