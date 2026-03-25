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

        const statusNode = this.element.querySelector(
            `[data-booking-id="${data.booking_id}"]`
        )
        if (statusNode) {
            const normalizedStatus = (data.status || "").toString().toLowerCase()
            const label = data.status_label || this.humanizeStatus(normalizedStatus)

            statusNode.textContent = label
            if (normalizedStatus) {
                statusNode.dataset.status = normalizedStatus
            }
        }
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
