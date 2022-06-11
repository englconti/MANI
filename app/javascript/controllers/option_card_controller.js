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

    const clickedCardValue = e.currentTarget.children[0].children[1].textContent;
    console.log(clickedCardValue);
    console.log(e.currentTarget.children[0])

    // Refactoring -------------------------------
    this.markCardValidation(clickedCardValue, "A", cardA, cardB, cardC, cardD);
    this.markCardValidation(clickedCardValue, "B", cardB, cardA, cardC, cardD);
    this.markCardValidation(clickedCardValue, "C", cardC, cardB, cardA, cardD);
    this.markCardValidation(clickedCardValue, "D", cardD, cardB, cardC, cardA);
    // --------------------------------------------

    // Feature to enable pressing confirm button only after selecting one option
    const confirmButton = document.getElementById("confirm-button")
    if (document.querySelector('.marked')) {
      confirmButton.removeAttribute("disabled");
    } else {
      confirmButton.disabled = true;
    }
  }

  markCardValidation = function (clickedCardValue, answerLetter, card1, card2, card3, card4) {
    if (clickedCardValue == answerLetter) {
      card1.classList.toggle('marked');
      if (card2.classList.contains('marked')) {
        card2.classList.remove('marked');
      }
      if (card3.classList.contains('marked')) {
        card3.classList.remove('marked');
      }
      if (card4.classList.contains('marked')) {
        card4.classList.remove('marked');
      }
    }
  }
}
