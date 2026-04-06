require 'rails_helper'

RSpec.describe "/api/v1/bookings", type: :request do
  let(:tenant) { create(:tenant, name: "Shaw College", slug: "shaw-college") }
  let(:user) { create(:user, :with_tenant, tenant: tenant) }
  let(:api_key) { create(:api_key, user: user) }
  let(:headers) { { "Authorization" => "Bearer #{api_key.token}" } }
  let(:venue) { create(:venue, name: "Room A", tenant: tenant, department: tenant.name) }

  describe "GET /api/v1/bookings" do
    let!(:booking) do
      VenueBooking.create!(
        user: user,
        venue: venue,
        start_time: 2.days.from_now.change(hour: 10, min: 0),
        end_time: 2.days.from_now.change(hour: 12, min: 0)
      )
    end

    it "returns user's bookings" do
      get "/api/v1/bookings", headers: headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["bookings"].length).to eq(1)
      expect(json["bookings"][0]["id"]).to eq(booking.id)
      expect(json["bookings"][0]["venue_name"]).to eq("Room A")
    end

    it "filters by status" do
      get "/api/v1/bookings", headers: headers, params: { status: "approved" }
      json = JSON.parse(response.body)
      expect(json["bookings"]).to be_empty
    end

    it "filters by type" do
      get "/api/v1/bookings", headers: headers, params: { type: "equipment" }
      json = JSON.parse(response.body)
      expect(json["bookings"]).to be_empty
    end

    it "returns pagination metadata" do
      get "/api/v1/bookings", headers: headers
      json = JSON.parse(response.body)
      expect(json["meta"]).to include("page", "per_page", "total", "total_pages")
    end

    it "rejects unauthenticated requests" do
      get "/api/v1/bookings"
      expect(response).to have_http_status(:unauthorized)
    end

    context "when user is admin" do
      let(:admin) { create(:user, :admin) }
      let(:admin_api_key) { create(:api_key, user: admin) }
      let(:admin_headers) { { "Authorization" => "Bearer #{admin_api_key.token}" } }

      it "returns all bookings" do
        get "/api/v1/bookings", headers: admin_headers
        json = JSON.parse(response.body)
        expect(json["bookings"].length).to eq(1)
      end
    end
  end

  describe "GET /api/v1/bookings/:id" do
    let!(:booking) do
      VenueBooking.create!(
        user: user,
        venue: venue,
        start_time: 2.days.from_now.change(hour: 10, min: 0),
        end_time: 2.days.from_now.change(hour: 12, min: 0)
      )
    end

    it "returns booking details" do
      get "/api/v1/bookings/#{booking.id}", headers: headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["booking"]["id"]).to eq(booking.id)
      expect(json["booking"]["type"]).to eq("VenueBooking")
      expect(json["booking"]["status"]).to eq("pending")
      expect(json["booking"]["venue_name"]).to eq("Room A")
      expect(json["booking"]["start_time"]).to be_present
      expect(json["booking"]["end_time"]).to be_present
    end

    it "returns 404 for another user's booking" do
      other_user = create(:user, :with_tenant)
      other_booking = VenueBooking.create!(
        user: other_user,
        venue: create(:venue, tenant: other_user.tenant, department: other_user.tenant.name),
        start_time: 3.days.from_now.change(hour: 10, min: 0),
        end_time: 3.days.from_now.change(hour: 12, min: 0)
      )
      get "/api/v1/bookings/#{other_booking.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/bookings" do
    context "creating a venue booking" do
      let(:valid_params) do
        {
          booking_type: "venue",
          venue_id: venue.id,
          start_time: 3.days.from_now.change(hour: 10, min: 0).iso8601,
          end_time: 3.days.from_now.change(hour: 12, min: 0).iso8601
        }
      end

      it "creates a venue booking" do
        expect {
          post "/api/v1/bookings", headers: headers, params: valid_params
        }.to change(VenueBooking, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["booking"]["type"]).to eq("VenueBooking")
        expect(json["booking"]["status"]).to eq("pending")
        expect(json["booking"]["venue_id"]).to eq(venue.id)
      end

      it "returns errors for invalid venue booking" do
        post "/api/v1/bookings", headers: headers, params: valid_params.merge(start_time: nil)
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Validation failed")
      end
    end

    context "creating an equipment booking" do
      let(:equipment) { create(:equipment, tenant: tenant, quantity: 5) }

      let(:valid_params) do
        {
          booking_type: "equipment",
          equipment_id: equipment.id,
          quantity: 2,
          start_date: 1.day.from_now.to_date.iso8601,
          end_date: 3.days.from_now.to_date.iso8601
        }
      end

      it "creates an equipment booking" do
        expect {
          post "/api/v1/bookings", headers: headers, params: valid_params
        }.to change(EquipmentBooking, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["booking"]["type"]).to eq("EquipmentBooking")
        expect(json["booking"]["quantity"]).to eq(2)
      end

      it "returns errors when exceeding available quantity" do
        post "/api/v1/bookings", headers: headers, params: valid_params.merge(quantity: 100)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it "returns error for missing booking_type" do
      post "/api/v1/bookings", headers: headers, params: { venue_id: venue.id }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["details"]).to include("Booking type must be 'venue' or 'equipment'")
    end
  end
end
