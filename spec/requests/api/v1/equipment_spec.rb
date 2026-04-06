require 'rails_helper'

RSpec.describe "/api/v1/equipment", type: :request do
  let(:tenant) { create(:tenant, name: "Shaw College", slug: "shaw-college") }
  let(:user) { create(:user, :with_tenant, tenant: tenant) }
  let(:api_key) { create(:api_key, user: user) }
  let(:headers) { { "Authorization" => "Bearer #{api_key.token}" } }

  let!(:equipment) { create(:equipment, name: "Projector", quantity: 5, tenant: tenant) }
  let!(:other_tenant) { create(:tenant, name: "Other College", slug: "other-college") }
  let!(:other_equipment) { create(:equipment, name: "Speaker", quantity: 3, tenant: other_tenant) }

  describe "GET /api/v1/equipment" do
    it "returns equipment visible to the user" do
      get "/api/v1/equipment", headers: headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      names = json["equipment"].map { |e| e["name"] }
      expect(names).to include("Projector")
    end

    it "includes availability info" do
      get "/api/v1/equipment", headers: headers
      json = JSON.parse(response.body)
      item = json["equipment"].find { |e| e["name"] == "Projector" }
      expect(item["total_quantity"]).to eq(5)
      expect(item["available_quantity"]).to eq(5)
    end

    it "reflects booked quantities in availability" do
      EquipmentBooking.create!(
        user: user,
        equipment: equipment,
        quantity: 2,
        start_date: 1.day.from_now.to_date,
        end_date: 3.days.from_now.to_date,
        status: :approved
      )

      get "/api/v1/equipment", headers: headers
      json = JSON.parse(response.body)
      item = json["equipment"].find { |e| e["name"] == "Projector" }
      expect(item["available_quantity"]).to eq(3)
    end

    it "returns paginated results" do
      get "/api/v1/equipment", headers: headers, params: { page: 1, per_page: 1 }
      json = JSON.parse(response.body)
      expect(json["meta"]["per_page"]).to eq(1)
    end

    it "rejects unauthenticated requests" do
      get "/api/v1/equipment"
      expect(response).to have_http_status(:unauthorized)
    end

    context "when user is admin" do
      let(:user) { create(:user, :admin) }

      it "returns all equipment" do
        get "/api/v1/equipment", headers: headers
        json = JSON.parse(response.body)
        names = json["equipment"].map { |e| e["name"] }
        expect(names).to include("Projector", "Speaker")
      end
    end
  end

  describe "GET /api/v1/equipment/:id" do
    it "returns equipment details" do
      get "/api/v1/equipment/#{equipment.id}", headers: headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["equipment"]["name"]).to eq("Projector")
      expect(json["equipment"]["total_quantity"]).to eq(5)
      expect(json["equipment"]["available_quantity"]).to eq(5)
    end

    it "returns 404 for non-visible equipment" do
      get "/api/v1/equipment/#{other_equipment.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
