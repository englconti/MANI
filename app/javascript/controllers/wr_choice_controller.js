import { Controller } from "stimulus"


export default class extends Controller {
  static targets = [ "option", "choice" ]

  connect() {
    console.log(this.optionTargets);

    const firstBlank = this.choiceTargets[0];
    const secondBlank = this.choiceTargets[1];
    const thirdBlank = this.choiceTargets[2];
    const fourthBlank = this.choiceTargets[3];
    // console.log(firstBlank)
    firstBlank.style.display = 'inline-block';
    if (secondBlank) { secondBlank.style.display = 'inline-block'; }
    if (thirdBlank) { thirdBlank.style.display = 'inline-block'; }
    if (fourthBlank) { fourthBlank.style.display = 'inline-block'; }
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
    this.selectTextToFillBlank(selectedTag, firstBlank, secondBlank, thirdBlank, fourthBlank)

  }

  selectTextToFillBlank = function (selection, firstBlank, secondBlank, thirdBlank, fourthBlank) {
    // console.log(selection)
    const blankArr = [firstBlank || "null", secondBlank || "null", thirdBlank || "null", fourthBlank || "s"]
    let cont = 0
    blankArr.forEach((blank) => {
      console.log("to")
      cont += blank.innerHTML == "_______" ? 1 : 0
      console.log(cont)
    })
      if (selection.classList.contains('highlight')) {
        selection.classList.remove('highlight');
        // Encontrar o blank que corresponde ao selection
        blankArr.forEach((blank) => {
          if (blank.innerHTML == selection.children[0].innerText) {
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
            blank.innerHTML = selection.children[0].innerText;
            blank.classList.add('filled-blank');
            break
          }
        }
      }
    }
  }
}
