require "rails_helper"

RSpec.describe SendgridEmailService do
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
  end
end
