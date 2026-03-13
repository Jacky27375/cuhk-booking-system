require 'rails_helper'

RSpec.describe "Equipment", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/equipment/index"
      expect(response).to have_http_status(:success)
    end
  end

end
