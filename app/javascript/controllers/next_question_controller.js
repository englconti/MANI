import { Controller } from "stimulus"
import { csrfToken } from "@rails/ujs"
import { right } from "@popperjs/core"

export default class extends Controller {

  connect() {
    console.log("teste")
    // 1. Feature to make the bar move -----
    this.barStatusLoad(0);
    // 2. Check last mute status -----------
    this.checkLastMuteStatus();
    // -------------------------------------

    // Added for merging controllers -------
    const questionType = document.querySelector(".container-parts").dataset.questionType
    if (questionType == "writing") {
      console.log("Question type: WRITING");
      this.choiceTargets.forEach((target) => {
        if (target) {
          target.style.display = 'inline-block'
        }
        console.log(target);
      })
    } else if (questionType == "abcd") {
      console.log("Question type: ABCD")
    }
    // End of merging -----------------------
  }

  confirmAbcd(event) {
    event.preventDefault();

    this.questionElement = document.querySelector("#questions-container");

    // 1. Getting the text content from the marked Card and puttinuserAnswer
    const userAnswer = document.querySelector(".marked").children[1].textContent;

    // 2. Defining the correct URL based on the server routes. OBS: Replace URL for Heroku deployment
    const urlPatch = `http://localhost:3000/answers/${this.questionElement.dataset.answerId}`;
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

    // 5. Enable next question button AND Lesson review btn at the end of lesson
    if (document.querySelector("#btn-next-question")) {
      document.querySelector("#btn-next-question").disabled = false;
    } else if (document.querySelector("#btn-lesson-review")) {
      document.querySelector("#btn-lesson-review").disabled = false;
    }

    // 6. Disable non-selected option cards
    const questionCards = document.querySelectorAll(".question-card");
    questionCards.forEach((questionCard) => {
      questionCard.style.pointerEvents = 'none';
      questionCard.classList.contains("marked") || questionCard.classList.add("question-card-greyed");
    })

    // 7. Playing sound and chaging card colors based on user answer
    const correctAnswer = document.querySelector("#correct-answer").textContent
    userAnswer === correctAnswer ? this.correctAnswerAction() : this.wrongAnswerAction();

    // 8. Feature to make the bar move -----
    this.barStatusLoad(1)

    // 9. Removing hearts if wrong confirmation (only view, true change happens on the answers_controller.rb)
    this.renderHearts(userAnswer === correctAnswer)
  }

  correctAnswerAction() {
    const audio = new Audio('http://codeskulptor-demos.commondatastorage.googleapis.com/descent/gotitem.mp3');
    document.querySelector('.correct-answer').removeAttribute("hidden");
    document.querySelector('.marked').classList.add("correct-answer-card");
    document.querySelector('.question-footer').classList.add("correct-answer-footer-style")
    console.log(localStorage["alerts"])
    localStorage["alerts"] === 'false' ? audio.muted : audio.play();
  }

  wrongAnswerAction() {
    const wrongAudio = new Audio('https://rpg.hamsterrepublic.com/wiki-images/d/d7/Oddbounce.ogg');
    document.querySelector('.marked').classList.add("wrong-answer-card");
    document.querySelector('.wrong-answer').removeAttribute("hidden");
    document.querySelector('.question-footer').classList.add("wrong-answer-footer-style")
    console.log(localStorage["alerts"])
    localStorage["alerts"] === 'false' ? wrongAudio.muted : wrongAudio.play();
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
