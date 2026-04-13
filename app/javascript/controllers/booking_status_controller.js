import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
    connect() {
        this.consumer = createConsumer()
        this.subscription = this.consumer.subscriptions.create("BookingStatusChannel", {
            connected: () => {
                this.element.dataset.bookingStatusConnection = "connected"
            },
            disconnected: () => {
                this.element.dataset.bookingStatusConnection = "disconnected"
            },
            rejected: () => {
                this.element.dataset.bookingStatusConnection = "rejected"
            },
            received: (data) => {
                this.updateStatus(data)
            }
        })
    }

    disconnect() {
        if (this.subscription) {
            this.subscription.unsubscribe()
        }
        if (this.consumer) {
            this.consumer.disconnect()
        }
    }

    updateStatus(data) {
        if (!data || !data.booking_id) {
            return
        }

        const normalizedStatus = (data.status || "").toString().toLowerCase()
        const label = data.status_label || this.humanizeStatus(normalizedStatus)

        const statusNode = this.element.querySelector(
            `[data-booking-status-id="${data.booking_id}"], [data-booking-id="${data.booking_id}"]`
        )
        if (statusNode) {
            statusNode.innerHTML = ""

            const badgeNode = document.createElement("span")
            badgeNode.className = `badge ${this.badgeClass(normalizedStatus)}`
            badgeNode.textContent = label
            statusNode.appendChild(badgeNode)

            if (normalizedStatus) {
                statusNode.dataset.status = normalizedStatus
            }
        }

        const rejectionReasonNode = this.element.querySelector(
            `[data-booking-rejection-reason-id="${data.booking_id}"]`
        )
        if (rejectionReasonNode) {
            rejectionReasonNode.textContent = this.rejectionReason(normalizedStatus, data.rejection_reason)
        }
    }

    badgeClass(status) {
        const mapping = {
            pending: "badge-pending",
            approved: "badge-approved",
            rejected: "badge-rejected",
            cancelled: "badge-cancelled",
            under_review: "badge-under-review",
            borrowed: "badge-borrowed",
            returned: "badge-returned"
        }

        return mapping[status] || "badge-pending"
    }

    rejectionReason(status, reason) {
        if (status !== "rejected") {
            return ""
        }

        const normalizedReason = (reason || "").toString().trim()
        return normalizedReason.length > 0 ? normalizedReason : "No reason provided"
    }

    humanizeStatus(status) {
        if (!status) {
            return "Unknown"
        }

        return status
            .split("_")
            .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
            .join(" ")
    }
}
