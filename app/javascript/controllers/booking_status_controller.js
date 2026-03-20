import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
    connect() {
        this.consumer = createConsumer()
        this.subscription = this.consumer.subscriptions.create("BookingStatusChannel", {
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
        const statusNode = this.element.querySelector(
            `[data-booking-id="${data.booking_id}"]`
        )
        if (statusNode) {
            statusNode.textContent = data.status
        }
    }
}
