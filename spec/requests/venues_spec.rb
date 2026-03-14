require 'rails_helper'

RSpec.describe "/venues", type: :request do
  let(:valid_attributes) {
    { name: "Lecture Sol 1", description: "Large hall for 200 people" }
  }

  let(:invalid_attributes) {
    { name: nil }
  }

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
  end

  describe "GET /show" do
    it "renders a successful response" do
      venue = Venue.create! valid_attributes
      get venue_url(venue)
      expect(response).to be_successful
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
