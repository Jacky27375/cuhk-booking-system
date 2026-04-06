require 'rails_helper'

RSpec.describe "/venues", type: :request do
  let(:valid_attributes) {
    { name: "Lecture Sol 1", description: "Large hall for 200 people", department: "Science Faculty" }
  }

  let(:invalid_attributes) {
    { name: nil }
  }

  let(:science_tenant) { create(:tenant, name: "Science Faculty") }
  let(:arts_tenant) { create(:tenant, name: "Arts Faculty") }

  let(:admin) { FactoryBot.create(:user, :admin) }

  before do
    log_in_as(admin)
  end

  describe "GET /index" do
    it "renders a successful response" do
      Venue.create! valid_attributes
      get venues_url
      expect(response).to be_successful
    end

    it "allows admin to see venues from all tenants" do
      create(:venue, name: "Science Room", tenant: science_tenant, department: science_tenant.name)
      create(:venue, name: "Arts Room", tenant: arts_tenant, department: arts_tenant.name)

      get venues_url

      expect(response).to be_successful
      expect(response.body).to include("Science Room")
      expect(response.body).to include("Arts Room")
    end

    it "scopes staff to venues in their tenant" do
      staff = create(:user, :staff, tenant: science_tenant)
      visible_venue = create(:venue, name: "Room 101", tenant: science_tenant, department: science_tenant.name)
      hidden_venue = create(:venue, name: "LT1", tenant: arts_tenant, department: arts_tenant.name)

      log_in_as(staff)
      get venues_url

      expect(response).to be_successful
      expect(response.body).to include(visible_venue.name)
      expect(response.body).not_to include(hidden_venue.name)
    end

    it "sorts by name ascending then descending and falls back to default" do
      create(:venue, name: "Zulu Room", tenant: science_tenant, department: science_tenant.name)
      create(:venue, name: "Alpha Room", tenant: science_tenant, department: science_tenant.name)

      get venues_url, params: { sort: "name", direction: "asc" }
      expect(response.body.index("Alpha Room")).to be < response.body.index("Zulu Room")

      get venues_url, params: { sort: "name", direction: "desc" }
      expect(response.body.index("Zulu Room")).to be < response.body.index("Alpha Room")

      get venues_url
      expect(response.body.index("Alpha Room")).to be < response.body.index("Zulu Room")
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      venue = Venue.create! valid_attributes
      get venue_url(venue)
      expect(response).to be_successful
    end

    it "prevents staff from opening venues in another tenant" do
      staff = create(:user, :staff, tenant: science_tenant)
      foreign_venue = create(:venue, tenant: arts_tenant, department: arts_tenant.name)

      log_in_as(staff)
      get venue_url(foreign_venue)

      expect(response).to redirect_to(venues_path)
      expect(flash[:alert]).to eq("You are not authorized to access this venue.")
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_venue_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      venue = Venue.create! valid_attributes
      get edit_venue_url(venue)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Venue" do
        expect {
          post venues_url, params: { venue: valid_attributes }
        }.to change(Venue, :count).by(1)
      end

      it "redirects to the created venue" do
        post venues_url, params: { venue: valid_attributes }
        expect(response).to redirect_to(venue_url(Venue.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Venue" do
        expect {
          post venues_url, params: { venue: invalid_attributes }
        }.to change(Venue, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post venues_url, params: { venue: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { name: "Updated Venue" }
      }

      it "updates the requested venue" do
        venue = Venue.create! valid_attributes
        patch venue_url(venue), params: { venue: new_attributes }
        venue.reload
        expect(venue.name).to eq("Updated Venue")
      end

      it "redirects to the venue" do
        venue = Venue.create! valid_attributes
        patch venue_url(venue), params: { venue: new_attributes }
        venue.reload
        expect(response).to redirect_to(venue_url(venue))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        venue = Venue.create! valid_attributes
        patch venue_url(venue), params: { venue: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested venue" do
      venue = Venue.create! valid_attributes
      expect {
        delete venue_url(venue)
      }.to change(Venue, :count).by(-1)
    end

    it "redirects to the venues list" do
      venue = Venue.create! valid_attributes
      delete venue_url(venue)
      expect(response).to redirect_to(venues_url)
    end
  end
end
