import { Controller } from "@hotwired/stimulus"

const HOUR_IN_MINUTES = 60

export default class extends Controller {
  static targets = ["startSelect", "endSelect"]
  static values = {
    unavailableRanges: Array,
    dayEnd: String,
    maxHours: Number
  }

  connect() {
    this.startChanged()
  }

  startChanged() {
    const startSlot = this.startSelectTarget.value

    if (!startSlot) {
      this.endSelectTarget.disabled = true
      this.resetEndOptions()
      return
    }

    this.endSelectTarget.disabled = false
    this.populateEndOptions(startSlot)
  }

  populateEndOptions(startSlot) {
    const previousSelection = this.endSelectTarget.value
    const startMinutes = this.timeToMinutes(startSlot)
    const dayEndMinutes = this.timeToMinutes(this.dayEndValue || "22:00")
    const maxHours = this.maxHoursValue || 4
    const maxEndMinutes = Math.min(startMinutes + (maxHours * HOUR_IN_MINUTES), dayEndMinutes)

    this.resetEndOptions()

    for (let endMinutes = startMinutes + HOUR_IN_MINUTES; endMinutes <= maxEndMinutes; endMinutes += HOUR_IN_MINUTES) {
      if (!this.rangeIsAvailable(startMinutes, endMinutes)) {
        continue
      }

      const option = document.createElement("option")
      option.value = this.minutesToTime(endMinutes)
      option.textContent = option.value
      this.endSelectTarget.appendChild(option)
    }

    if (this.optionExists(previousSelection)) {
      this.endSelectTarget.value = previousSelection
    }
  }

  resetEndOptions() {
    this.endSelectTarget.innerHTML = ""

    const blankOption = document.createElement("option")
    blankOption.value = ""
    blankOption.textContent = "Select end time"
    this.endSelectTarget.appendChild(blankOption)
    this.endSelectTarget.value = ""
  }

  rangeIsAvailable(rangeStartMinutes, rangeEndMinutes) {
    return (this.unavailableRangesValue || []).every((range) => {
      const start = this.timeToMinutes(range.start)
      const finish = this.timeToMinutes(range.end)

      return !(rangeStartMinutes < finish && rangeEndMinutes > start)
    })
  }

  optionExists(value) {
    if (!value) {
      return false
    }

    return Array.from(this.endSelectTarget.options).some((option) => option.value === value)
  }

  timeToMinutes(timeValue) {
    const parts = (timeValue || "").split(":")
    if (parts.length !== 2) {
      return 0
    }

    const hours = Number(parts[0])
    const minutes = Number(parts[1])
    return (hours * 60) + minutes
  }

  minutesToTime(totalMinutes) {
    const hours = String(Math.floor(totalMinutes / 60)).padStart(2, "0")
    const minutes = String(totalMinutes % 60).padStart(2, "0")
    return `${hours}:${minutes}`
  }
}
