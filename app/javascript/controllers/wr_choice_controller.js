import { Controller } from "stimulus"


export default class extends Controller {
  static targets = [ "option", "choice" ]

  connect() {
    // console.log(this.optionTargets);

    // Defining the blanks inside the statement
    const firstBlank = this.choiceTargets[0];
    const secondBlank = this.choiceTargets[1];
    const thirdBlank = this.choiceTargets[2];
    const fourthBlank = this.choiceTargets[3];
    // console.log(firstBlank)
    // Making the blanks stay on the same line instead of breaking into paragraphs
    if (firstBlank) { firstBlank.style.display = 'inline-block'; }
    if (secondBlank) { secondBlank.style.display = 'inline-block'; }
    if (thirdBlank) { thirdBlank.style.display = 'inline-block'; }
    if (fourthBlank) { fourthBlank.style.display = 'inline-block'; }

    // To keep the user selection of the mute or unmute button even after page refresh.
    const unMuteBtn = document.getElementById("sound");
    const muteBtn = document.getElementById("no-sound");
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
    const unMuteBtn = document.getElementById("sound");
    unMuteBtn.hidden = false;
    localStorage.setItem('alerts', false);
  }

  unMute(event) {
    event.currentTarget.setAttribute("hidden", true);
    const muteBtn = document.getElementById("no-sound");
    muteBtn.hidden = false;
    localStorage.setItem('alerts', true);
  }

  select(e) {
    e.preventDefault()
    // console.log(e.currentTarget.children[0].innerText);
    const firstBlank = this.choiceTargets[0];
    const secondBlank = this.choiceTargets[1];
    const thirdBlank = this.choiceTargets[2];
    const fourthBlank = this.choiceTargets[3];
    const selectedTag = e.currentTarget;
    // console.log(fourthBlank)

    const userSelection = this.selectTextToFillBlank(selectedTag, firstBlank, secondBlank, thirdBlank, fourthBlank)
    // console.log(userSelection)
    return userSelection
  }

  selectTextToFillBlank = function (selection, firstBlank, secondBlank, thirdBlank, fourthBlank) {
    // console.log(selection)
    const addedWord = selection.children[0].innerText;
    const wordsSelected = [];
    const blankArr = [firstBlank || "null", secondBlank || "null", thirdBlank || "null", fourthBlank || "s"]
    let cont = 0
    blankArr.forEach((blank) => {
      // console.log("to")
      cont += blank.innerHTML == "_______" ? 1 : 0
      // console.log(cont)
    })
      blankArr.forEach((nonBlank) => {
        if (nonBlank.innerText !== "_______" && nonBlank.innerText) {
          // To keep what is added from select(e) method above to the array wordsSelected
          wordsSelected.push(nonBlank.innerText)
        }
      })
        if (selection.classList.contains('highlight')) {
          selection.classList.remove('highlight');
          // Encontrar o blank que corresponde ao selection
          blankArr.forEach((blank) => {
            if (blank.innerHTML == addedWord) {
              blank.innerHTML = "_______";
              blank.classList.remove('filled-blank');
            }
          })
        } else {
          // Adicionar o highlight ao elemento selecionado e trocar o blank pelo texto selecionado
            if (cont !== 0) {
            selection.classList.add('highlight');
              for (const blank of blankArr) {
                if (blank.innerHTML == "_______") {
                  blank.innerHTML = addedWord;
                  blank.classList.add('filled-blank');
                  wordsSelected.push(addedWord)
                  break
                }
              }
            }
          }
    // Feature to enable pressing confirm button only after selecting one option
      cont = 0;
      blankArr.forEach((blank) => {
        // console.log("to")
        cont += blank.innerHTML == "_______" ? 1 : 0
        // console.log(cont)
      })
      const confirmButton = document.getElementById("wr-confirm-button");
      if (cont == 0) {
        confirmButton.removeAttribute("disabled");
      } else {
        confirmButton.disabled = true;
      }
    // console.log("End of condition")
    // console.log(wordsSelected)
    return wordsSelected
  }

  confirm(event) {
    event.preventDefault();

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

    const correctAnswer = document.querySelector("#wr-correct-answer").textContent.split(' ')
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
}
