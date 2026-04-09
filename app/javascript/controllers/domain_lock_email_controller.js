import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["localPart", "fullPreview"]
  static values = {
    domain: { type: String, default: "link.cuhk.edu.hk" }
  }

  connect() {
    this.sanitize()
    this.updatePreview()
  }

  sanitize() {
    if (!this.hasLocalPartTarget) {
      return
    }

    const rawValue = this.localPartTarget.value.toString()
    const sanitized = rawValue.split("@", 2)[0].replace(/\s+/g, "")
    if (sanitized !== rawValue) {
      this.localPartTarget.value = sanitized
    }
  }

  updatePreview() {
    if (!this.hasFullPreviewTarget || !this.hasLocalPartTarget) {
      return
    }

    const localPart = this.localPartTarget.value.toString().trim()
    const fallback = `yourid@${this.domainValue}`
    this.fullPreviewTarget.textContent = localPart ? `${localPart}@${this.domainValue}` : fallback
  }
}
