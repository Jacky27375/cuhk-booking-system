require 'rails_helper'

RSpec.describe "/bookings", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:venue) { FactoryBot.create(:venue) }

  let(:valid_attributes) {
    { venue_id: venue.id, start_time: 1.day.from_now, end_time: 1.day.from_now + 2.hours }
  }

  let(:invalid_attributes) {
    { start_time: nil }
  }

  before do
    log_in_as(user)
  end

  describe "GET /index" do
    let(:admin) { FactoryBot.create(:user, :admin) }

    before do
      log_in_as(admin)
    end

    it "renders a successful response" do
      Booking.create! valid_attributes.merge(user: user)
      get bookings_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      booking = Booking.create! valid_attributes.merge(user: user)
      get booking_url(booking)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_booking_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      booking = Booking.create! valid_attributes.merge(user: user)
      get edit_booking_url(booking)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Booking" do
        expect {
          post bookings_url, params: { booking: valid_attributes }
        }.to change(Booking, :count).by(1)
      end

      it "redirects to the created booking" do
        post bookings_url, params: { booking: valid_attributes }
        expect(response).to redirect_to(booking_url(Booking.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Booking" do
        expect {
          post bookings_url, params: { booking: invalid_attributes }
        }.to change(Booking, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post bookings_url, params: { booking: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { start_time: 2.days.from_now }
      }

      it "updates the requested booking" do
        booking = Booking.create! valid_attributes.merge(user: user)
        patch booking_url(booking), params: { booking: new_attributes }
        booking.reload
        expect(booking.start_time).to be_within(1.second).of(new_attributes[:start_time])
      end

      it "redirects to the booking" do
        booking = Booking.create! valid_attributes.merge(user: user)
        patch booking_url(booking), params: { booking: new_attributes }
        booking.reload
        expect(response).to redirect_to(booking_url(booking))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        booking = Booking.create! valid_attributes.merge(user: user)
        patch booking_url(booking), params: { booking: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested booking" do
      booking = Booking.create! valid_attributes.merge(user: user)
      expect {
        delete booking_url(booking)
      }.to change(Booking, :count).by(-1)
    end

    it "redirects to the bookings list" do
      booking = Booking.create! valid_attributes.merge(user: user)
      delete booking_url(booking)
      expect(response).to redirect_to(bookings_url)
    end
  end
end
