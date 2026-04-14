import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startDate", "endDate"]
  static values = { minimumDate: String }

  connect() {
    this.syncEndDateMinimum()
  }

  syncEndDateMinimum() {
    const minimumDate = this.startDateTarget.value || this.minimumDateValue || this.endDateTarget.min

    if (minimumDate) {
      this.endDateTarget.min = minimumDate
    }

    if (this.endDateTarget.value && minimumDate && this.endDateTarget.value < minimumDate) {
      this.endDateTarget.value = minimumDate
    }
  }
}
