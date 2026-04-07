import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    type: String,
    labels: Array,
    data: Array,
    label: String,
    colors: Array,
    suffix: { type: String, default: "" },
    stepSize: { type: Number, default: 1 }
  }

  connect() {
    const Chart = globalThis.Chart
    if (!Chart) { console.error("Chart.js not loaded"); return }

    const ctx = this.canvasTarget.getContext("2d")
    const defaultColors = [
      "#4dc9f6", "#f67019", "#f53794", "#537bc4",
      "#acc236", "#166a8f", "#00a950", "#58595b",
      "#8549ba", "#e6194b", "#3cb44b", "#ffe119"
    ]
    const colors = this.hasColorsValue ? this.colorsValue : defaultColors.slice(0, this.dataValue.length)
    const suffix = this.suffixValue

    const isCartesian = this.typeValue !== "pie" && this.typeValue !== "doughnut"

    new Chart(ctx, {
      type: this.typeValue,
      data: {
        labels: this.labelsValue,
        datasets: [{
          label: this.labelValue,
          data: this.dataValue,
          backgroundColor: colors,
          borderColor: this.typeValue === "line" ? colors[0] : colors,
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: { display: !isCartesian },
          tooltip: suffix ? {
            callbacks: {
              label: (ctx) => `${ctx.dataset.label}: ${ctx.parsed.y}${suffix}`
            }
          } : {}
        },
        scales: isCartesian ? {
          y: {
            beginAtZero: true,
            ticks: {
              stepSize: this.stepSizeValue,
              callback: (value) => `${value}${suffix}`
            }
          }
        } : {}
      }
    })
  }
}
