import { Controller } from "stimulus"
const cardA = document.querySelector('#questionA');
const cardB = document.querySelector('#questionB');
const cardC = document.querySelector('#questionC');
const cardD = document.querySelector('#questionD');

export default class extends Controller {
  static targets = [ "content" ]

  connect() {
    // console.log(this.contentTarget)
    console.log("Connected:", this.element);
  }

  markCard(e) {
    e.preventDefault();
    // this.contentTarget.classList.toggle('marked');
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
  }
}
