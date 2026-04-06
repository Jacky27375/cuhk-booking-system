require 'rails_helper'

RSpec.describe "/api/v1/venues", type: :request do
  let(:tenant) { create(:tenant, name: "Shaw College", slug: "shaw-college") }
  let(:user) { create(:user, :with_tenant, tenant: tenant) }
  let(:api_key) { create(:api_key, user: user) }
  let(:headers) { { "Authorization" => "Bearer #{api_key.token}" } }

  let!(:venue) { create(:venue, name: "Room A", tenant: tenant, department: tenant.name) }
  let!(:other_tenant) { create(:tenant, name: "Other College", slug: "other-college") }
  let!(:other_venue) { create(:venue, name: "Room B", tenant: other_tenant, department: other_tenant.name) }

  describe "GET /api/v1/venues" do
    it "returns venues visible to the user" do
      get "/api/v1/venues", headers: headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      venue_names = json["venues"].map { |v| v["name"] }
      expect(venue_names).to include("Room A")
    end

    it "returns paginated results" do
      get "/api/v1/venues", headers: headers, params: { page: 1, per_page: 1 }
      json = JSON.parse(response.body)
      expect(json["meta"]["per_page"]).to eq(1)
      expect(json["meta"]["total"]).to be >= 1
    end

    it "rejects unauthenticated requests" do
      get "/api/v1/venues"
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects invalid API keys" do
      get "/api/v1/venues", headers: { "Authorization" => "Bearer invalid_token" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects expired API keys" do
      api_key.update!(expires_at: 1.day.ago)
      get "/api/v1/venues", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects inactive API keys" do
      api_key.update!(active: false)
      get "/api/v1/venues", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end

    context "when user is admin" do
      let(:user) { create(:user, :admin) }

      it "returns all venues" do
        get "/api/v1/venues", headers: headers
        json = JSON.parse(response.body)
        venue_names = json["venues"].map { |v| v["name"] }
        expect(venue_names).to include("Room A", "Room B")
      end
    end
  end

  describe "GET /api/v1/venues/:id" do
    it "returns venue details" do
      get "/api/v1/venues/#{venue.id}", headers: headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["venue"]["name"]).to eq("Room A")
      expect(json["venue"]["department"]).to eq(tenant.name)
      expect(json["venue"]["id"]).to eq(venue.id)
    end

    it "returns 404 for non-visible venue" do
      get "/api/v1/venues/#{other_venue.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
