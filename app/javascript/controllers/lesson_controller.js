import { Controller } from "stimulus"
import { playCorrect, playWrong, soundEnabled, setSoundEnabled } from "../lesson/sounds"

// Drives one question screen (multiple choice or "writing" fill-in-the-blanks).
// The server grades the answer; this controller only collects it and shows the result.
export default class extends Controller {
  static targets = ["option", "word", "check", "continue", "feedback", "bar", "hearts",
                    "heartsCount", "soundToggle", "footer"]
  static values = {
    type: String,
    answerUrl: String,
    index: Number,
    count: Number,
    lives: Number,
    nextUrl: String,
    reviewUrl: String,
    last: Boolean
  }

  connect() {
    this.checked = false
    this.renderProgress(this.indexValue)
    this.renderSoundToggle()
  }

  // --- Choosing an answer ------------------------------------------------

  select() {
    if (this.checked) return
    this.optionTargets.forEach((option) => {
      option.closest(".question-card").classList.toggle("marked", option.checked)
    })
    this.checkTarget.disabled = !this.optionTargets.some((option) => option.checked)
  }

  toggleWord(event) {
    if (this.checked) return
    const button = event.currentTarget
    const filled = this.blanks.find((blank) => blank.dataset.source === button.id)

    if (filled) {
      this.clearBlank(filled)
      this.setWordSelected(button, false)
    } else {
      const empty = this.blanks.find((blank) => !blank.dataset.source)
      if (!empty) return
      empty.textContent = button.dataset.word
      empty.dataset.source = button.id
      empty.classList.add("filled-blank")
      this.setWordSelected(button, true)
    }
    this.checkTarget.disabled = this.blanks.some((blank) => !blank.dataset.source)
  }

  get blanks() {
    return Array.from(this.element.querySelectorAll(".fill-ins"))
  }

  clearBlank(blank) {
    blank.textContent = "_______"
    delete blank.dataset.source
    blank.classList.remove("filled-blank")
  }

  setWordSelected(button, selected) {
    button.classList.toggle("highlight", selected)
    button.setAttribute("aria-pressed", selected)
  }

  userAnswer() {
    if (this.typeValue === "writing") {
      return this.blanks.map((blank) => blank.textContent.trim()).join(" ")
    }
    const chosen = this.optionTargets.find((option) => option.checked)
    return chosen ? chosen.value : ""
  }

  // --- Checking ------------------------------------------------------------

  async check() {
    if (this.checked || this.checkTarget.disabled) return
    this.checkTarget.disabled = true
    const checkLabel = this.checkTarget.textContent
    this.checkTarget.textContent = "Verificando..."

    let result
    try {
      const response = await fetch(this.answerUrlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content
        },
        body: JSON.stringify({ answer: this.userAnswer() })
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      result = await response.json()
    } catch (error) {
      this.showFeedback("Não foi possível enviar sua resposta. Tente de novo.", "is-error")
      this.checkTarget.textContent = checkLabel
      this.checkTarget.disabled = false
      return
    }

    this.checked = true
    this.showResult(result)
  }

  showResult(result) {
    this.lockInputs()
    const stateClass = result.correct ? "correct-answer-card" : "wrong-answer-card"
    this.element.querySelectorAll(".marked, .wr-question-card.highlight").forEach((card) => {
      card.classList.add(stateClass)
    })
    this.footerTarget.classList.add(result.correct ? "correct-answer-footer-style" : "wrong-answer-footer-style")

    if (result.correct) {
      this.showFeedback("Resposta correta!", "is-correct", result.explanation)
      playCorrect()
    } else {
      this.revealCorrectOption(result.correct_option)
      const answer = result.correct_answer_text || result.correct_answer_label
      this.showFeedback(`A resposta correta é: ${answer}`, "is-wrong", result.explanation)
      playWrong()
    }

    this.livesValue = result.lives
    this.renderLives()
    this.renderProgress(this.indexValue + 1)
    this.showContinue(result)
  }

  lockInputs() {
    this.optionTargets.forEach((option) => {
      option.disabled = true
      const card = option.closest(".question-card")
      if (!card.classList.contains("marked")) card.classList.add("question-card-greyed")
    })
    this.wordTargets.forEach((word) => {
      word.disabled = true
      if (!word.classList.contains("highlight")) word.classList.add("question-card-greyed")
    })
  }

  // Wrong answer with no lives left: go straight to the lesson summary
  showContinue(result) {
    const outOfLives = !result.correct && result.lives === 0 && !this.lastValue
    const toSummary = this.lastValue || outOfLives
    this.continueTarget.href = outOfLives ? this.reviewUrlValue : this.nextUrlValue
    this.continueTarget.textContent = toSummary ? "Ver resumo" : "Continuar"
    this.checkTarget.hidden = true
    this.continueTarget.hidden = false
    this.continueTarget.focus()
  }

  // After a wrong answer, mark the option that was right (not only the one picked)
  revealCorrectOption(letter) {
    if (!letter) return
    const option = this.optionTargets.find((candidate) => candidate.value === letter)
    if (!option) return
    const card = option.closest(".question-card")
    card.classList.remove("question-card-greyed")
    card.classList.add("correct-answer-card")
  }

  showFeedback(message, state, explanation = null) {
    this.feedbackTarget.className = `answer-feedback ${state}`
    this.feedbackTarget.textContent = message
    if (explanation) {
      const note = document.createElement("span")
      note.className = "answer-explanation"
      note.textContent = explanation
      this.feedbackTarget.appendChild(note)
    }
  }

  // --- Progress, lives, sound -----------------------------------------------

  renderProgress(done) {
    const percent = this.countValue > 0 ? Math.min(100, (done / this.countValue) * 100) : 0
    this.barTarget.style.width = `${percent}%`
    this.barTarget.parentElement.setAttribute("aria-valuenow", done)
  }

  renderLives() {
    this.heartsCountTarget.textContent = this.livesValue
    this.heartsTarget.setAttribute("aria-label", `${this.livesValue} ${this.livesValue === 1 ? "vida" : "vidas"}`)
  }

  toggleSound() {
    setSoundEnabled(!soundEnabled())
    this.renderSoundToggle()
  }

  renderSoundToggle() {
    const on = soundEnabled()
    const button = this.soundToggleTarget
    button.setAttribute("aria-pressed", on)
    button.setAttribute("aria-label", on ? "Desligar o som" : "Ligar o som")
    button.querySelector("i").className = on ? "fas fa-volume-up" : "fas fa-volume-mute"
  }

  // --- Keyboard shortcuts -----------------------------------------------------

  key(event) {
    if (event.altKey || event.ctrlKey || event.metaKey) return
    const interactive = event.target.closest("button, a, input[type=text]")

    if (this.typeValue === "abcd" && !this.checked) {
      const index = "abcd1234".indexOf(event.key.toLowerCase()) % 4
      if (event.key.length === 1 && "abcd1234".includes(event.key.toLowerCase()) && this.optionTargets[index]) {
        this.optionTargets[index].click()
        return
      }
    }

    if (event.key === "Enter" && !interactive) {
      if (this.checked) {
        this.continueTarget.click()
      } else {
        this.check()
      }
    }
  }
}
