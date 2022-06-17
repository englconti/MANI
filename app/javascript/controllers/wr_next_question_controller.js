import { Controller } from "stimulus"
import { csrfToken } from "@rails/ujs"
import { right } from "@popperjs/core"

export default class extends Controller {
  static targets = [ "option", "choice" ]

  connect() {
    console.log("controller wr_next_question connected!");

    // 2. Check last mute status -----------
    this.checkLastMuteStatus();
    console.log("final")
  }

  confirmWr(event) {
    event.preventDefault();
    console.log("ConfirmWr clicked")

    this.questionElement = document.querySelector("#questions-container");

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
    const muteBtn = document.getElementById("sound-off");
    const unMuteBtn = document.getElementById("sound-on")
    let isCorrect = true
    userAnswer.forEach((word, index) => {
      if (word !== correctAnswer[index]) {
        isCorrect = false;
      }
    });
    if (isCorrect) {
      document.querySelector('.correct-answer').removeAttribute("hidden");
      document.querySelector('.highlight').classList.add("correct-answer-card");
      document.querySelector('.question-footer').classList.add("correct-answer-footer-style")
      // console.log(localStorage["alerts"])
      localStorage["alerts"] === 'false' ? audio.muted : audio.play();
    } else {
      document.querySelector('.highlight').classList.add("wrong-answer-card");
      document.querySelector('.wrong-answer').removeAttribute("hidden");
      document.querySelector('.question-footer').classList.add("wrong-answer-footer-style")
      // console.log(localStorage["alerts"])
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
