require "rails_helper"

RSpec.describe ResendEmailService do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, :with_tenant, tenant: tenant, email: "test@link.cuhk.edu.hk") }
  let(:venue) { create(:venue, tenant: tenant, department: tenant.name) }
  let(:booking) do
    VenueBooking.create!(
      user: user,
      venue: venue,
      start_time: 5.days.from_now.change(hour: 10, min: 0),
      end_time: 5.days.from_now.change(hour: 12, min: 0)
    )
  end

  let(:equipment) { create(:equipment, tenant: tenant, quantity: 5) }
  let(:equipment_booking) do
    EquipmentBooking.create!(
      user: user,
      equipment: equipment,
      quantity: 2,
      start_date: 5.day.from_now.to_date,
      end_date: 7.days.from_now.to_date
    )
  end

  describe ".send_booking_approved" do
    context "when RESEND_API_KEY is not set" do
      before { allow(ENV).to receive(:[]).and_call_original }

      it "logs a warning and returns nil" do
        allow(ENV).to receive(:[]).with("RESEND_API_KEY").and_return(nil)
        allow(ENV).to receive(:fetch).and_call_original

        expect(Rails.logger).to receive(:warn).with(/RESEND_API_KEY not set/)
        result = described_class.send_booking_approved(booking)
        expect(result).to be_nil
      end
    end

    context "when RESEND_API_KEY is set" do
      let(:success_response) { { "id" => "email_123" } }

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("RESEND_API_KEY").and_return("re_test_key")
        allow(ENV).to receive(:fetch).and_call_original

        allow(Resend::Emails).to receive(:send).and_return(success_response)
      end

      it "sends an approved email via Resend API" do
        result = described_class.send_booking_approved(booking)
        expect(result).to eq(success_response)
        expect(Resend::Emails).to have_received(:send).with(hash_including(
          to: ["test@link.cuhk.edu.hk"],
          subject: /Booking Approved/
        ))
      end

      it "sends an approved email for equipment bookings" do
        result = described_class.send_booking_approved(equipment_booking)
        expect(result).to eq(success_response)
        expect(Resend::Emails).to have_received(:send)
      end
    end
  end

  describe ".send_booking_rejected" do
    context "when RESEND_API_KEY is set" do
      let(:success_response) { { "id" => "email_456" } }

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("RESEND_API_KEY").and_return("re_test_key")
        allow(ENV).to receive(:fetch).and_call_original

        allow(Resend::Emails).to receive(:send).and_return(success_response)
      end

      it "sends a rejected email with reason" do
        result = described_class.send_booking_rejected(booking, reason: "Conflict with another booking")
        expect(result).to eq(success_response)
      end

      it "sends a rejected email without reason" do
        result = described_class.send_booking_rejected(booking)
        expect(result).to eq(success_response)
      end
    end
  end

  describe ".send_email" do
    context "when API returns an error" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("RESEND_API_KEY").and_return("re_test_key")
        allow(ENV).to receive(:fetch).and_call_original

        allow(Resend::Emails).to receive(:send).and_return({ "error" => "Forbidden" })
      end

      it "raises a DeliveryError" do
        expect {
          described_class.send_email(to: "test@link.cuhk.edu.hk", subject: "Test", html_content: "<p>Test</p>")
        }.to raise_error(ResendEmailService::DeliveryError)
      end
    end
  end
end
