import { Controller } from "stimulus"

// Counts the reward numbers up from zero (skipped when the user prefers less motion).
export default class extends Controller {
  static targets = ["number"]

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    this.numberTargets.forEach((element) => this.countUp(element))
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
