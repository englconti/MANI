import { Controller } from "stimulus"
import { csrfToken } from "@rails/ujs"

export default class extends Controller {

  connect() {
  }

  confirm(event) {
    event.preventDefault()
    this.element.innerText = "Lets Go!"
    this.element.setAttribute("hidden", true)

    this.questionElement = document.querySelector("#questions-container");

    // 1. Getting the text content from the marked Card and puttinuserAnswer
    const userAnswer = document.querySelector(".marked").children[0].children[0].textContent

    // 2. Defining the correct URL based on the server routes. OBS: it will need to be change for Heroku deployment
    // const urlPatch = `http://localhost:3000/answers/${this.questionElement.dataset.answerId}`;
    const urlPatch = `https://mani-finance.herokuapp.com/answers/${this.questionElement.dataset.answerId}`;

    // 3. Creating a JS Object with the data we want to send to the server
    const data = { answer: userAnswer, answer_id: this.questionElement.dataset.answerId }

    // 4. Send data to correct route - In this case PATCH, since we will only be updating answers.
    fetch(urlPatch, {
      method: "PATCH",
      headers: {
                  "Content-type": "application/json",
                  "Accept": "application/json",
                  "X-CSRF-Token": csrfToken()
                },
      body: JSON.stringify(data)
    })

    // 5. Enable/Show next question button
    const nextQuestionBtn = document.querySelector("#btn-next-question");
    nextQuestionBtn.disabled = false;

    // 6. Disable non-selected option cards
    const questionCards = document.querySelectorAll(".question-card");

    questionCards.forEach((questionCard) => {
      // console.log(questionCard.classList.contains("marked"));
      if (!questionCard.classList.contains("marked")) {
        questionCard.classList.add("disabled-question-card");
        questionCard.classList.remove("question-card");
        questionCard.classList.remove(questionCard.classList[0]);
      } else {
        questionCard.classList.remove(questionCard.classList[1]);
      }

    });
  }
}
