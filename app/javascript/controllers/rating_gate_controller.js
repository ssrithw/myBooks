import { Controller } from "@hotwired/stimulus"

// Controller to enforce that only finished or abandoned books can be rated. 
// It disables the rating while the status is "To read" or "Reading"

export default class extends Controller {
  static targets = ["status", "rating", "hint"]
  static values = { rateable: Array }

  connect() {
    this.sync()
  }

  sync() {
    const allowed = this.rateableValue.includes(this.statusTarget.value)

    this.ratingTarget.disabled = !allowed
    if (!allowed) this.ratingTarget.value = ""
    if (this.hasHintTarget) this.hintTarget.hidden = allowed
  }
}
