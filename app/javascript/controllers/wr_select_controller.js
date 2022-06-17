import { Controller } from "stimulus"
import { csrfToken } from "@rails/ujs"
import { right } from "@popperjs/core"

export default class extends Controller {
  static targets = [ "option", "choice" ];

  connect() {
    console.log("controller wr_select connected!");
    // 1. Alignning all blank spaces on view
    this.choiceTargets.forEach((target) => {
      if (target) {
        target.style.display = 'inline-block';
      }
    })
    // 2. Check last mute status -----------
    this.checkLastMuteStatus();
  }

  select(e) {
    e.preventDefault();
    const firstBlank = this.choiceTargets[0];
    const secondBlank = this.choiceTargets[1];
    const thirdBlank = this.choiceTargets[2];
    const fourthBlank = this.choiceTargets[3];
    const selectedTag = e.currentTarget;
    const userSelection = this.selectTextToFillBlank(selectedTag, firstBlank, secondBlank, thirdBlank, fourthBlank);
    return userSelection;
  }

  selectTextToFillBlank = function (selection, firstBlank, secondBlank, thirdBlank, fourthBlank) {
    const addedWord = selection.children[0].innerText;
    const wordsSelected = [];
    const blankArr = [firstBlank || "null", secondBlank || "null", thirdBlank || "null", fourthBlank || "s"];
    let cont = 0;
    blankArr.forEach((blank) => {
      cont += blank.innerHTML == "_______" ? 1 : 0
    })
      blankArr.forEach((nonBlank) => {
        if (nonBlank.innerText !== "_______" && nonBlank.innerText) {
          wordsSelected.push(nonBlank.innerText);
        }
      })
        if (selection.classList.contains('highlight')) {
          selection.classList.remove('highlight');
          blankArr.forEach((blank) => {
            if (blank.innerHTML == addedWord) {
              blank.innerHTML = "_______";
              blank.classList.remove('filled-blank');
            }
          })
        } else {
            if (cont !== 0) {
            selection.classList.add('highlight');
              for (const blank of blankArr) {
                if (blank.innerHTML == "_______") {
                  blank.innerHTML = addedWord;
                  blank.classList.add('filled-blank');
                  wordsSelected.push(addedWord);
                  break;
                }
              }
            }
          }
    // Feature to enable pressing confirm button only after selecting one option
      cont = 0;
      blankArr.forEach((blank) => {
        cont += blank.innerHTML == "_______" ? 1 : 0;
      })
      const confirmButton = document.getElementById("confirm-button");
      if (cont == 0) {
        confirmButton.removeAttribute("disabled");
      } else {
        confirmButton.disabled = true;
      }
    return wordsSelected;
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
