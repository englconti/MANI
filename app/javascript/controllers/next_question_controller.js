import { Controller } from "stimulus"
import { csrfToken } from "@rails/ujs"
import { right } from "@popperjs/core"

export default class extends Controller {

  connect() {
    console.log("next_question connected")
    // 0. Feature to make the bar move -----
    this.barStatusLoad(0)
    // -------------------------------------
    const unMuteBtn = document.getElementById("sound-on");
    const muteBtn = document.getElementById("sound-off");
    // console.log(localStorage['alerts'])
    // To keep the user selection of the mute or unmute button even after page refresh.
    if (localStorage["alerts"] === 'true') {
      muteBtn.hidden = false;
      unMuteBtn.hidden = true;
    } else {
      unMuteBtn.hidden = false;
      muteBtn.hidden = true;
    }
  }

  mute(event) {
    event.currentTarget.setAttribute("hidden", true);
    const unMuteBtn = document.getElementById("sound-on");
    unMuteBtn.hidden = false;
    localStorage.setItem('alerts', false);
  }

  unMute(event) {
    event.currentTarget.setAttribute("hidden", true);
    const muteBtn = document.getElementById("sound-off");
    muteBtn.hidden = false;
    localStorage.setItem('alerts', true);
  }

  confirm(event) {
    event.preventDefault();

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
    const audio = new Audio('http://codeskulptor-demos.commondatastorage.googleapis.com/descent/gotitem.mp3');
    const wrongAudio = new Audio('https://rpg.hamsterrepublic.com/wiki-images/d/d7/Oddbounce.ogg');
    const muteBtn = document.getElementById("sound-off");
    const unMuteBtn = document.getElementById("sound-on")
    if (userAnswer === correctAnswer) {
      document.querySelector('.correct-answer').removeAttribute("hidden");
      document.querySelector('.marked').classList.add("correct-answer-card");
      document.querySelector('.question-footer').classList.add("correct-answer-footer-style")
      console.log(localStorage["alerts"])
      localStorage["alerts"] === 'false' ? audio.muted : audio.play();
    } else {
      document.querySelector('.marked').classList.add("wrong-answer-card");
      document.querySelector('.wrong-answer').removeAttribute("hidden");
      document.querySelector('.question-footer').classList.add("wrong-answer-footer-style")
      console.log(localStorage["alerts"])
      localStorage["alerts"] === 'false' ? audio.muted : wrongAudio.play();
    }

    // 7. Feature to make the bar move -----
    this.barStatusLoad(1)
    // -------------------------------------

    // 8. Removing hearts if wrong confirmation (only view, true change happens on the answers_controller.rb)
    this.renderHearts(userAnswer === correctAnswer)
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

  renderHearts = function (correctGuess) {
    const hearts = document.querySelector(".hearts");
    const heartsAmount = hearts.dataset.heartsAmount;
    const lastQuestion = hearts.dataset.lastQuestion === "true";
    const heartsArray = ["🖤🖤🖤🖤🖤", "💗🖤🖤🖤🖤", "💗💗🖤🖤🖤", "💗💗💗🖤🖤", "💗💗💗💗🖤","💗💗💗💗💗"]
    hearts.innerHTML = correctGuess ? heartsArray[+heartsAmount] : heartsArray[+heartsAmount - 1]

    // Logic to replace next-lesson button for lesson-review if meet criteria
    if (!correctGuess && (heartsAmount - 1 == 0) && !lastQuestion) {
      const nextQuestionBtn = document.querySelector("#btn-next-question");
      const lessonReviewButton = document.querySelector("#btn-lesson-review")
      nextQuestionBtn.disabled = true;
      nextQuestionBtn.hidden = true;
      lessonReviewButton.hidden = false;
      lessonReviewButton.disabled = false;
    }
  }
}
