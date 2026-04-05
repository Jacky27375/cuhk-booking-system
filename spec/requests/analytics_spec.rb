require "rails_helper"
require "nokogiri"

RSpec.describe "Analytics", type: :request do
  let(:tenant) { create(:tenant, name: "University", slug: "university") }
  let(:admin) { create(:user, :admin, tenant: tenant) }
  let(:staff) { create(:user, :staff, tenant: tenant) }
  let(:member) { create(:user, :society_member, tenant: tenant) }
  let(:venue) { create(:venue, tenant: tenant, department: tenant.name) }
  let(:equipment) { create(:equipment, tenant: tenant, name: "Projector", quantity: 5) }

  describe "GET /analytics" do
    def chart_data_values_for(title)
      doc = Nokogiri::HTML(response.body)
      heading = doc.css("h2").find { |node| node.text.strip == title }
      return nil unless heading

      chart_container = heading.parent.at_css("div[data-controller='chart']")
      return nil unless chart_container

      chart_container["data-chart-data-value"]
    end

    context "as admin" do
      before { log_in_as(admin) }

      it "renders successfully" do
        get analytics_path
        expect(response).to be_successful
      end

      it "displays the analytics dashboard heading" do
        get analytics_path
        expect(response.body).to include("Analytics Dashboard")
      end

      context "with booking data" do
        before do
          create(:booking, user: member, venue: venue,
                           start_time: Time.zone.now.change(hour: 10, min: 0),
                           end_time: Time.zone.now.change(hour: 12, min: 0))
          create(:booking, user: member, venue: venue,
                           start_time: 1.day.from_now.change(hour: 14, min: 0),
                           end_time: 1.day.from_now.change(hour: 16, min: 0),
                           status: :approved)
        end

        it "shows summary stats" do
          get analytics_path
          expect(response.body).to include("Total Bookings")
          expect(response.body).to include("Pending")
          expect(response.body).to include("Approved")
        end

        it "shows venue booking chart data" do
          get analytics_path
          expect(response.body).to include("Bookings per Venue")
          expect(response.body).to include(venue.name)
        end

        it "shows peak hours chart" do
          get analytics_path
          expect(response.body).to include("Peak Booking Hours")
        end

        it "shows venue duration chart" do
          get analytics_path
          expect(response.body).to include("Total Booked Hours per Venue")
        end

        it "shows venue occupancy chart" do
          get analytics_path
          expect(response.body).to include("Venue Occupancy Rate")
        end

        it "shows weekly trend chart" do
          get analytics_path
          expect(response.body).to include("Weekly Booking Trend")
        end

        it "shows day-of-week chart" do
          get analytics_path
          expect(response.body).to include("Bookings by Day of Week")
        end
      end

      context "with equipment data" do
        before do
          create(:equipment_booking, user: member, equipment: equipment,
                                     start_date: Date.current, end_date: 3.days.from_now.to_date,
                                     quantity: 2)
        end

        it "shows equipment borrow count chart" do
          get analytics_path
          expect(response.body).to include("Equipment Borrow Count")
          expect(response.body).to include("Projector")
        end

        it "shows equipment quantity borrowed chart" do
          get analytics_path
          expect(response.body).to include("Total Units Borrowed per Equipment")
        end

        it "shows equipment booking status chart" do
          get analytics_path
          expect(response.body).to include("Equipment Booking Status")
        end

        it "shows equipment summary card" do
          get analytics_path
          expect(response.body).to include("Equipment")
        end
      end

      context "with no data" do
        it "shows empty state messages" do
          get analytics_path
          expect(response.body).to include("No venue bookings yet.")
          expect(response.body).to include("No equipment borrowing data yet.")
        end
      end
    end

    context "date range filtering" do
      before { log_in_as(admin) }

      it "accepts start_date and end_date params" do
        get analytics_path, params: { start_date: "2026-03-01", end_date: "2026-03-15" }
        expect(response).to be_successful
        expect(response.body).to include("2026-03-01")
        expect(response.body).to include("2026-03-15")
      end

      it "handles reversed date range gracefully" do
        get analytics_path, params: { start_date: "2026-03-31", end_date: "2026-03-01" }
        expect(response).to be_successful
        expect(response.body).to include("2026-03-01")
        expect(response.body).to include("2026-03-31")
      end

      it "handles invalid date params gracefully" do
        get analytics_path, params: { start_date: "not-a-date", end_date: "also-bad" }
        expect(response).to be_successful
      end

      it "filters bookings within the specified range" do
        create(:booking, user: member, venue: venue,
                         start_time: Time.zone.parse("2026-01-10 10:00"),
                         end_time: Time.zone.parse("2026-01-10 12:00"),
                         created_at: Time.zone.parse("2026-01-10"))
        create(:booking, user: member, venue: venue,
                         start_time: Time.zone.parse("2026-03-10 10:00"),
                         end_time: Time.zone.parse("2026-03-10 12:00"),
                         created_at: Time.zone.parse("2026-03-10"))

        get analytics_path, params: { start_date: "2026-03-01", end_date: "2026-03-31" }
        expect(chart_data_values_for("Bookings per Venue")).to eq("[1]")
      end

      it "filters equipment metrics within the specified range" do
        create(:equipment_booking, user: member, equipment: equipment,
                                   start_date: Date.parse("2026-01-10"),
                                   end_date: Date.parse("2026-01-12"),
                                   quantity: 3,
                                   created_at: Time.zone.parse("2026-01-10"))

        create(:equipment_booking, user: member, equipment: equipment,
                                   start_date: Date.parse("2026-03-10"),
                                   end_date: Date.parse("2026-03-12"),
                                   quantity: 2,
                                   created_at: Time.zone.parse("2026-03-10"))

        get analytics_path, params: { start_date: "2026-03-01", end_date: "2026-03-31" }

        expect(chart_data_values_for("Equipment Borrow Count")).to eq("[1]")
        expect(chart_data_values_for("Total Units Borrowed per Equipment")).to eq("[2]")
      end
    end

    context "as staff" do
      before { log_in_as(staff) }

      it "renders successfully" do
        get analytics_path
        expect(response).to be_successful
      end
    end

    context "as society member" do
      before { log_in_as(member) }

      it "redirects to root with unauthorized message" do
        get analytics_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get analytics_path
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
