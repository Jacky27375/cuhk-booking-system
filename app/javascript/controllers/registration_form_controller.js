import { Controller } from "@hotwired/stimulus"

const PASSWORD_LENGTH = 14
const UPPERCASE = "ABCDEFGHJKLMNPQRSTUVWXYZ"
const LOWERCASE = "abcdefghijkmnopqrstuvwxyz"
const NUMBERS = "23456789"
const SYMBOLS = "!@#$%^&*()-_=+[]{}?"

export default class extends Controller {
  static targets = [
    "password",
    "passwordConfirmation",
    "minLengthRule",
    "confirmationRule",
    "rulesSummary",
    "generatedPanel",
    "generatedPassword",
    "copyFeedback"
  ]

  connect() {
    this.updateRules()
  }

  updateRules() {
    const password = this.passwordTarget.value.toString()
    const confirmation = this.passwordConfirmationTarget.value.toString()

    const hasMinimumLength = password.length >= 8
    const confirmationMatches = confirmation.length > 0 && password === confirmation

    this.applyRuleState(this.minLengthRuleTarget, hasMinimumLength)
    this.applyRuleState(this.confirmationRuleTarget, confirmationMatches)

    if (hasMinimumLength && confirmationMatches) {
      this.rulesSummaryTarget.textContent = "Password requirements satisfied."
    } else {
      this.rulesSummaryTarget.textContent = "Please satisfy all password requirements."
    }
  }

  generatePassword(event) {
    event.preventDefault()

    const password = this.buildPassword()
    this.passwordTarget.value = password
    this.passwordConfirmationTarget.value = password

    this.generatedPanelTarget.hidden = false
    this.generatedPasswordTarget.textContent = password
    this.copyFeedbackTarget.textContent = ""

    this.updateRules()
  }

  async copyGeneratedPassword(event) {
    event.preventDefault()

    const password = this.generatedPasswordTarget.textContent.toString().trim()
    if (!password) {
      this.copyFeedbackTarget.textContent = "Nothing to copy."
      return
    }

    try {
      await navigator.clipboard.writeText(password)
      this.copyFeedbackTarget.textContent = "Copied."
    } catch (_error) {
      this.copyFeedbackTarget.textContent = "Copy failed."
    }
  }

  applyRuleState(ruleNode, passed) {
    ruleNode.classList.toggle("passed", passed)
    ruleNode.classList.toggle("pending", !passed)
  }

  buildPassword() {
    const requiredSets = [UPPERCASE, LOWERCASE, NUMBERS, SYMBOLS]
    const allCharacters = `${UPPERCASE}${LOWERCASE}${NUMBERS}${SYMBOLS}`

    const passwordCharacters = requiredSets.map((set) => this.randomCharacter(set))
    while (passwordCharacters.length < PASSWORD_LENGTH) {
      passwordCharacters.push(this.randomCharacter(allCharacters))
    }

    this.shuffle(passwordCharacters)
    return passwordCharacters.join("")
  }

  randomCharacter(characterSet) {
    return characterSet[this.randomIndex(characterSet.length)]
  }

  randomIndex(max) {
    if (window.crypto && window.crypto.getRandomValues) {
      const values = new Uint32Array(1)
      window.crypto.getRandomValues(values)
      return values[0] % max
    }

    return Math.floor(Math.random() * max)
  }

  shuffle(array) {
    for (let i = array.length - 1; i > 0; i -= 1) {
      const j = this.randomIndex(i + 1)
      const tmp = array[i]
      array[i] = array[j]
      array[j] = tmp
    }
  }
}
