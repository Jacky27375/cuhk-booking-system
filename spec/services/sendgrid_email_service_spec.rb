require "rails_helper"

RSpec.describe SendgridEmailService do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, :with_tenant, tenant: tenant, email: "test@cuhk.edu.hk") }
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
    context "when SENDGRID_API_KEY is not set" do
      before { allow(ENV).to receive(:[]).and_call_original }

      it "logs a warning and returns nil" do
        allow(ENV).to receive(:[]).with("SENDGRID_API_KEY").and_return(nil)
        allow(ENV).to receive(:fetch).and_call_original

        expect(Rails.logger).to receive(:warn).with(/SENDGRID_API_KEY not set/)
        result = described_class.send_booking_approved(booking)
        expect(result).to be_nil
      end
    end

    context "when SENDGRID_API_KEY is set" do
      let(:mock_response) { double("Response", status_code: "202", body: "") }
      let(:mock_client) { double("Client") }
      let(:mock_mail_endpoint) { double("MailEndpoint") }
      let(:mock_sg) { double("SendGrid::API", client: mock_client) }

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SENDGRID_API_KEY").and_return("SG.test_key")
        allow(ENV).to receive(:fetch).and_call_original

        allow(SendGrid::API).to receive(:new).and_return(mock_sg)
        allow(mock_client).to receive(:mail).and_return(mock_client)
        allow(mock_client).to receive(:_).with("send").and_return(mock_mail_endpoint)
        allow(mock_mail_endpoint).to receive(:post).and_return(mock_response)
      end

      it "sends an approved email via SendGrid API" do
        result = described_class.send_booking_approved(booking)
        expect(result).to eq(mock_response)
        expect(mock_mail_endpoint).to have_received(:post)
      end

      it "sends an approved email for equipment bookings" do
        result = described_class.send_booking_approved(equipment_booking)
        expect(result).to eq(mock_response)
        expect(mock_mail_endpoint).to have_received(:post)
      end
    end
  end

  describe ".send_booking_rejected" do
    context "when SENDGRID_API_KEY is set" do
      let(:mock_response) { double("Response", status_code: "202", body: "") }
      let(:mock_client) { double("Client") }
      let(:mock_mail_endpoint) { double("MailEndpoint") }
      let(:mock_sg) { double("SendGrid::API", client: mock_client) }

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SENDGRID_API_KEY").and_return("SG.test_key")
        allow(ENV).to receive(:fetch).and_call_original

        allow(SendGrid::API).to receive(:new).and_return(mock_sg)
        allow(mock_client).to receive(:mail).and_return(mock_client)
        allow(mock_client).to receive(:_).with("send").and_return(mock_mail_endpoint)
        allow(mock_mail_endpoint).to receive(:post).and_return(mock_response)
      end

      it "sends a rejected email with reason" do
        result = described_class.send_booking_rejected(booking, reason: "Conflict with another booking")
        expect(result).to eq(mock_response)
      end

      it "sends a rejected email without reason" do
        result = described_class.send_booking_rejected(booking)
        expect(result).to eq(mock_response)
      end
    end
  end

  describe ".send_email" do
    context "when API returns an error" do
      let(:mock_response) { double("Response", status_code: "403", body: "Forbidden") }
      let(:mock_client) { double("Client") }
      let(:mock_mail_endpoint) { double("MailEndpoint") }
      let(:mock_sg) { double("SendGrid::API", client: mock_client) }

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SENDGRID_API_KEY").and_return("SG.test_key")
        allow(ENV).to receive(:fetch).and_call_original

        allow(SendGrid::API).to receive(:new).and_return(mock_sg)
        allow(mock_client).to receive(:mail).and_return(mock_client)
        allow(mock_client).to receive(:_).with("send").and_return(mock_mail_endpoint)
        allow(mock_mail_endpoint).to receive(:post).and_return(mock_response)
      end

      it "raises a DeliveryError" do
        expect {
          described_class.send_email(to: "test@example.com", subject: "Test", html_content: "<p>Test</p>")
        }.to raise_error(SendgridEmailService::DeliveryError, /403/)
      end
    end
  end
end
