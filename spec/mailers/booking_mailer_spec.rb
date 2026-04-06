require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, :with_tenant, tenant: tenant, email: "student@link.cuhk.edu.hk") }
  let(:venue) { create(:venue, name: "Room A", tenant: tenant, department: tenant.name) }
  let(:booking) do
    VenueBooking.create!(
      user: user,
      venue: venue,
      start_time: 2.days.from_now.change(hour: 10, min: 0),
      end_time: 2.days.from_now.change(hour: 12, min: 0)
    )
  end

  describe "#approved" do
    let(:mail) { described_class.with(booking: booking).approved }

    it "sends to the booking user's email" do
      expect(mail.to).to eq(["student@link.cuhk.edu.hk"])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Booking Approved")
    end

    it "includes the venue name in the body" do
      expect(mail.body.encoded).to include("Room A")
    end

    it "sends from the configured from address" do
      expect(mail.from).to include(ENV.fetch("SENDGRID_FROM_EMAIL", "noreply@csci3100.tylerl.cyou"))
    end
  end

  describe "#rejected" do
    let(:reason) { "Conflict with another event" }
    let(:mail) { described_class.with(booking: booking, reason: reason).rejected }

    it "sends to the booking user's email" do
      expect(mail.to).to eq(["student@link.cuhk.edu.hk"])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Booking Rejected")
    end

    it "includes the rejection reason in the body" do
      expect(mail.body.encoded).to include("Conflict with another event")
    end

    it "includes the venue name in the body" do
      expect(mail.body.encoded).to include("Room A")
    end
  end
end
