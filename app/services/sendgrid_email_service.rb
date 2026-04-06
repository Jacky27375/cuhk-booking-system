# Service wrapper for sending emails via the SendGrid Web API v3.
# This provides a direct API integration (vs SMTP relay) and is used
# for booking notification emails.
#
# Usage:
#   SendgridEmailService.send_booking_approved(booking)
#   SendgridEmailService.send_booking_rejected(booking, reason: "Conflict")
#
class SendgridEmailService
  class DeliveryError < StandardError; end

  FROM_EMAIL = ENV.fetch("SENDGRID_FROM_EMAIL", "noreply@csci3100.tylerl.cyou")
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
      api_key = ENV["SENDGRID_API_KEY"]
      unless api_key.present?
        Rails.logger.warn("[SendGrid] SENDGRID_API_KEY not set — falling back to ActionMailer")
        return nil
      end

      from = SendGrid::Email.new(email: FROM_EMAIL, name: FROM_NAME)
      to_email = SendGrid::Email.new(email: to)
      content = SendGrid::Content.new(type: "text/html", value: html_content)
      mail = SendGrid::Mail.new(from, subject, to_email, content)

      sg = SendGrid::API.new(api_key: api_key)
      response = sg.client.mail._("send").post(request_body: mail.to_json)

      unless response.status_code.to_i.between?(200, 299)
        Rails.logger.error("[SendGrid] Email delivery failed: #{response.status_code} #{response.body}")
        raise DeliveryError, "SendGrid API returned #{response.status_code}"
      end

      Rails.logger.info("[SendGrid] Email sent to #{to}: #{subject} (#{response.status_code})")
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
