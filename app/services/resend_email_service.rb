# Service wrapper for sending emails via the Resend API.
# Used for booking notification emails (approval/rejection).
#
# Usage:
#   ResendEmailService.send_booking_approved(booking)
#   ResendEmailService.send_booking_rejected(booking, reason: "Conflict")
#
class ResendEmailService
  class DeliveryError < StandardError; end

  FROM_EMAIL = ENV.fetch("RESEND_FROM_EMAIL", "onboarding@resend.dev")
  FROM_NAME  = "CUHK Booking System"

  class << self
    def send_booking_approved(booking)
      subject = "Booking Approved - #{booking_resource_name(booking)}"
      body = approved_email_body(booking)
      send_email(to: booking.user.email, subject: subject, html_content: body)
    end

    def send_booking_rejected(booking, reason: nil)
      subject = "Booking Rejected - #{booking_resource_name(booking)}"
      body = rejected_email_body(booking, reason)
      send_email(to: booking.user.email, subject: subject, html_content: body)
    end

    def send_email(to:, subject:, html_content:)
      api_key = ENV["RESEND_API_KEY"]
      unless api_key.present?
        Rails.logger.warn("[Resend] RESEND_API_KEY not set — falling back to ActionMailer")
        return nil
      end

      Resend.api_key = api_key
      recipient = to

      params = {
        from: "#{FROM_NAME} <#{FROM_EMAIL}>",
        to: [recipient],
        subject: subject,
        html: html_content
      }

      response = Resend::Emails.send(params)

      if response.is_a?(Hash) && response["id"].present?
        Rails.logger.info("[Resend] Email sent to #{recipient}: #{subject} (id: #{response['id']})")
      else
        Rails.logger.error("[Resend] Email delivery failed: #{response.inspect}")
        raise DeliveryError, "Resend API error: #{response.inspect}"
      end

      response
    end

    private

    def booking_resource_name(booking)
      if booking.respond_to?(:venue) && booking.venue.present?
        booking.venue.name
      elsif booking.respond_to?(:equipment) && booking.equipment.present?
        booking.equipment.name
      else
        "Booking ##{booking.id}"
      end
    end

    def approved_email_body(booking)
      <<~HTML
        <h2>Booking Approved</h2>
        <p>Your booking for <strong>#{booking_resource_name(booking)}</strong> has been approved.</p>
        #{booking_details_html(booking)}
        <p>If you have any questions, please contact the facility administrator.</p>
      HTML
    end

    def rejected_email_body(booking, reason)
      reason_text = reason.present? ? reason : "No reason provided"
      <<~HTML
        <h2>Booking Rejected</h2>
        <p>Your booking for <strong>#{booking_resource_name(booking)}</strong> has been rejected.</p>
        <p><strong>Reason:</strong> #{reason_text}</p>
        #{booking_details_html(booking)}
        <p>Please contact the facility administrator if you have questions.</p>
      HTML
    end

    def booking_details_html(booking)
      if booking.is_a?(VenueBooking)
        <<~HTML
          <p><strong>Venue:</strong> #{booking.venue&.name}</p>
          <p><strong>Time:</strong> #{booking.start_time&.strftime('%B %d, %Y %H:%M')} - #{booking.end_time&.strftime('%H:%M')}</p>
        HTML
      elsif booking.is_a?(EquipmentBooking)
        <<~HTML
          <p><strong>Equipment:</strong> #{booking.equipment&.name}</p>
          <p><strong>Quantity:</strong> #{booking.quantity}</p>
          <p><strong>Period:</strong> #{booking.start_date} - #{booking.end_date}</p>
        HTML
      else
        ""
      end
    end
  end
end
