import { Controller } from "@hotwired/stimulus"

// This is used to control the theme of the application.
// The website uses light theme by default.
// The light and dark modes are controlled by buttons 
// which update after selecting a new theme.

const THEMES = ["light", "dark"]

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.apply(this.saved() || "light")
  }

  set({ params: { name } }) {
    if (!THEMES.includes(name)) return // reject unknown names

    // save the chosen theme for later visits
    this.apply(name)
    try { localStorage.setItem("theme", name) } catch (error) { /* storage can be blocked by e.g. browser incognito mode */ }
  }

  apply(name) {
    document.documentElement.dataset.theme = name
    this.buttonTargets.forEach((button) => {
      button.setAttribute("aria-pressed", String(button.dataset.themeNameParam === name))
    })
  }

  // get saved theme or apply default
  saved() {
    try {
      const theme = localStorage.getItem("theme")
      return THEMES.includes(theme) ? theme : null
    } catch (error) {
      return null
    }
  }
}

