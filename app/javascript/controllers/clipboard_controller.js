import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "feedback"]
  static values = {
    copiedText: { type: String, default: "Copied." },
    failedText: { type: String, default: "Copy failed." }
  }

  async copy() {
    const text = this.sourceTarget?.textContent?.trim()
    if (!text) {
      return
    }

    try {
      await navigator.clipboard.writeText(text)
      this.feedbackTarget.textContent = this.copiedTextValue
    } catch (_error) {
      this.feedbackTarget.textContent = this.failedTextValue
    }
  }
}
