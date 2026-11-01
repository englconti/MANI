import { Controller } from "stimulus"
import { playSuccess } from "../lesson/sounds"
import { launchCelebration } from "../lesson/effects"

// The end of a lesson: a success sound (when the sound is on), confetti and fireworks (unless the
// user prefers less motion) and the reward numbers counting up from zero.
export default class extends Controller {
  static targets = ["number"]
  static values = { stars: Number }

  connect() {
    const stars = this.starsValue || 1
    playSuccess(stars)

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    this.stopEffect = launchCelebration(stars)
    this.numberTargets.forEach((element) => this.countUp(element))
  }

  disconnect() {
    if (this.stopEffect) this.stopEffect()
  }

  countUp(element) {
    const target = parseInt(element.dataset.celebrationValue, 10) || 0
    if (target === 0) return

    const duration = 900
    const start = performance.now()
    const step = (now) => {
      const progress = Math.min((now - start) / duration, 1)
      element.textContent = Math.round(target * progress)
      if (progress < 1) requestAnimationFrame(step)
    }
    element.textContent = 0
    requestAnimationFrame(step)
  }
}
