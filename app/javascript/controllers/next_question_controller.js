import { Controller } from "stimulus"
import { csrfToken } from "@rails/ujs"
import { right } from "@popperjs/core"

export default class extends Controller {

  connect() {
    console.log("next_question connected")
    // 0. Feature to make the bar move -----
    this.barStatusLoad(0)
    // -------------------------------------
  }

  confirm(event) {
    event.preventDefault();

    this.element.setAttribute("hidden", true);

    this.questionElement = document.querySelector("#questions-container");

    // 1. Getting the text content from the marked Card and puttinuserAnswer
    const userAnswer = document.querySelector(".marked").children[1].textContent;
    // console.log(userAnswer)

    // 2. Defining the correct URL based on the server routes. OBS: it will need to be change for Heroku deployment
    const urlPatch = `http://localhost:3000/answers/${this.questionElement.dataset.answerId}`;

    // for Heroku comment the above line and uncomment this one
    // const urlPatch = `https://mani-finance.herokuapp.com/answers/${this.questionElement.dataset.answerId}`;

    // 3. Creating a JS Object with the data we want to send to the server
    const data = { answer: userAnswer, answer_id: this.questionElement.dataset.answerId };

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

    // 5. Enable/Show next question button AND Lesson review btn at the end of lesson
    if (document.querySelector("#btn-next-question")) {
      const nextQuestionBtn = document.querySelector("#btn-next-question");
      nextQuestionBtn.disabled = false;
    } else if (document.querySelector("#btn-lesson-review")) {
      const lessonReviewButton = document.querySelector("#btn-lesson-review")
      lessonReviewButton.disabled = false;
    }

    // 6. Disable non-selected option cards
    const questionCards = document.querySelectorAll(".question-card");

    questionCards.forEach((questionCard) => {
      questionCard.style.pointerEvents = 'none';
      if (!questionCard.classList.contains("marked")) {
        questionCard.classList.add("question-card-greyed");
      }
    })

    const correctAnswer = document.querySelector("#correct-answer").textContent

    if (userAnswer === correctAnswer) {
      document.querySelector('.correct-answer').removeAttribute("hidden");
      document.querySelector('.marked').classList.add("correct-answer-card");
    } else {
      document.querySelector('.marked').classList.add("wrong-answer-card");
      document.querySelector('.wrong-answer').removeAttribute("hidden");
    }

      // 7. Feature to make the bar move -----
      this.barStatusLoad(1)
      // -------------------------------------
  }

  barStatusLoad = function (num) {
      const questionElement = document.querySelector("#questions-container");
      const currentQuestionId = questionElement.dataset.questionId;
      const questionsCount = questionElement.dataset.lessonQuestionsCount;
      const firstQuestionId = questionElement.dataset.firstQuestionId;
      const progress = (currentQuestionId - firstQuestionId + num) * (60 / questionsCount);
      const progressBar = document.querySelector(".bar-container");
      progressBar.style = `width: ${progress}vw;`
  }
}
