require "rails_helper"

RSpec.describe AnalyticsController, type: :routing do
  describe "routing" do
    it "routes GET /analytics to analytics#show" do
      expect(get: "/analytics").to route_to("analytics#show")
    end

    it "does not route POST /analytics" do
      expect(post: "/analytics").not_to be_routable
    end
  end
end
