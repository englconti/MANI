import { Controller } from "stimulus"
import { csrfToken } from "@rails/ujs"
import { right } from "@popperjs/core"

export default class extends Controller {
  static targets = [ "option", "choice" ];

  connect() {
    console.log("controller wr_next_question connected!");
    // 1. Feature to make the bar move -----
    this.barStatusLoad(0);
    // 2. Check last mute status -----------
    this.checkLastMuteStatus();
  }

  confirmWr(event) {
    event.preventDefault();
    console.log("ConfirmWr clicked");

    // Getting the text content from the marked Card and puttinuserAnswer
    const userAnswerArr = document.querySelectorAll('.fill-ins');
    const userAnswer = [];
    userAnswerArr.forEach((ans) => {
      userAnswer.push(ans.innerText);
    })

    // Disable non-selected option cards
    const questionCards = document.querySelectorAll(".wr-question-card");

    questionCards.forEach((questionCard) => {
      questionCard.style.pointerEvents = 'none';
      if (!questionCard.classList.contains("highlight")) {
        questionCard.classList.add("question-card-greyed");
      }
    })

    const correctAnswer = document.querySelector("#correct-answer").textContent.split(' ')
    const audio = new Audio('http://codeskulptor-demos.commondatastorage.googleapis.com/descent/gotitem.mp3');
    const wrongAudio = new Audio('https://rpg.hamsterrepublic.com/wiki-images/d/d7/Oddbounce.ogg');
    let isCorrect = true
    userAnswer.forEach((word, index) => {
      console.log(`word: ${word}`)
      if (word !== correctAnswer[index]) {
        isCorrect = false;
      }
    });
    console.log(`isCorrect: ${isCorrect}`);
    if (isCorrect) {
      document.querySelector('.correct-answer').removeAttribute("hidden");
      document.querySelector('.highlight').classList.add("correct-answer-card");
      document.querySelector('.question-footer').classList.add("correct-answer-footer-style");
      localStorage["alerts"] === 'false' ? audio.muted : audio.play();
    } else {
      document.querySelector('.highlight').classList.add("wrong-answer-card");
      document.querySelector('.wrong-answer').removeAttribute("hidden");
      document.querySelector('.question-footer').classList.add("wrong-answer-footer-style");
      localStorage["alerts"] === 'false' ? audio.muted : wrongAudio.play();
    }

    // Enable/Show next question button AND Lesson review btn at the end of lesson
    if (document.querySelector("#btn-next-question")) {
      const nextQuestionBtn = document.querySelector("#btn-next-question");
      nextQuestionBtn.disabled = false;
    } else if (document.querySelector("#btn-lesson-review")) {
      const lessonReviewButton = document.querySelector("#btn-lesson-review")
      lessonReviewButton.disabled = false;
    }

    // POST answer on server ---------------------------
    // this.questionElement = document.querySelector("#questions-container");
    this.questionElement = document.querySelector(".container-parts");


    // Defining the correct URL based on the server routes. OBS: Replace URL for Heroku deployment
    // const urlPatch = `http://localhost:3000/answers/${this.questionElement.dataset.answerId}`;
    const urlPatch = `https://mani-finance.herokuapp.com/answers/${this.questionElement.dataset.answerId}`;

    // Creating a JS Object with the data we want to send to the server
    const data = { answer: isCorrect, answer_id: this.questionElement.dataset.answerId, question_type: this.questionElement.dataset.questionType };

    // Send data to correct route - In this case PATCH, since we will only be updating answers.
    fetch(urlPatch, {
      method: "PATCH",
      headers: {
                  "Content-type": "application/json",
                  "Accept": "application/json",
                  "X-CSRF-Token": csrfToken()
                },
      body: JSON.stringify(data)
    })
    // END of POST --------------------------------------

    // Feature to make the bar move -----
    this.barStatusLoad(1);

    // Removing hearts if wrong confirmation (only view, true change happens on the answers_controller.rb)
    this.renderHearts(isCorrect);
  }

  barStatusLoad = function (num) {
    const currentQuestionIndex = document.querySelector("#question-buttons").dataset.questionIndex
    console.log(`Current question index: ${currentQuestionIndex}`)
    const questionElement = document.querySelector("#questions-container");
    const questionsCount = questionElement.dataset.lessonQuestionsCount;
    const progress = (+currentQuestionIndex + num) * (60 / questionsCount);
    const progressBar = document.querySelector(".bar-container");
    progressBar.style = `width: ${progress}vw;`
  }

  renderHearts = function (correctGuess) {
    const hearts = document.querySelector(".hearts");
    const heartsAmount = hearts.dataset.heartsAmount;
    const lastQuestion = hearts.dataset.lastQuestion === "true";
    const heartsArray = ["🖤🖤🖤🖤🖤", "💗🖤🖤🖤🖤", "💗💗🖤🖤🖤", "💗💗💗🖤🖤", "💗💗💗💗🖤","💗💗💗💗💗"];
    hearts.innerHTML = correctGuess ? heartsArray[+heartsAmount] : heartsArray[+heartsAmount - 1];

    // Logic to replace next-lesson button for lesson-review if meet criteria
    if (!correctGuess && (heartsAmount - 1 == 0) && !lastQuestion) {
      const nextQuestionBtn = document.querySelector("#btn-next-question");
      const lessonReviewButton = document.querySelector("#btn-lesson-review");
      nextQuestionBtn.disabled = true;
      nextQuestionBtn.hidden = true;
      lessonReviewButton.hidden = false;
      lessonReviewButton.disabled = false;
    }
  }

  checkLastMuteStatus() {
    const unMuteBtn = document.getElementById("sound-on");
    const muteBtn = document.getElementById("sound-off");
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
}
