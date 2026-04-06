require 'rails_helper'

RSpec.describe "/bookings", type: :request do
  let(:tenant) { create(:tenant, name: "University", slug: "university") }
  let(:user) { FactoryBot.create(:user, tenant: tenant) }
  let(:venue) { FactoryBot.create(:venue, tenant: tenant, department: tenant.name) }

  let(:valid_attributes) {
    {
      venue_id: venue.id,
      start_time: Time.zone.parse("2026-04-10 10:00:00"),
      end_time: Time.zone.parse("2026-04-10 12:00:00")
    }
  }

  let(:invalid_attributes) {
    { venue_id: venue.id, start_time: nil, end_time: valid_attributes[:end_time] }
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
      VenueBooking.create! valid_attributes.merge(user: user)
      get bookings_url
      expect(response).to be_successful
    end

    it "shows bookings from all tenants for admin" do
      science_tenant = create(:tenant, name: "Science Faculty")
      arts_tenant = create(:tenant, name: "Arts Faculty")
      science_member = create(:user, tenant: science_tenant)
      arts_member = create(:user, tenant: arts_tenant)
      science_venue = create(:venue, name: "Science Hall", department: science_tenant.name, tenant: science_tenant)
      arts_venue = create(:venue, name: "Arts Hall", department: arts_tenant.name, tenant: arts_tenant)
      create(:booking, venue: science_venue, user: science_member, status: :pending)
      create(:booking, venue: arts_venue, user: arts_member, status: :pending)

      get bookings_url

      expect(response).to be_successful
      expect(response.body).to include("Science Hall")
      expect(response.body).to include("Arts Hall")
    end

    it "shows only bookings in staff tenant for staff" do
      science_tenant = create(:tenant, name: "Science Faculty")
      arts_tenant = create(:tenant, name: "Arts Faculty")
      staff = create(:user, :staff, tenant: science_tenant)
      science_member = create(:user, tenant: science_tenant)
      arts_member = create(:user, tenant: arts_tenant)
      science_venue = create(:venue, name: "Science Hall", department: science_tenant.name, tenant: science_tenant)
      arts_venue = create(:venue, name: "Arts Hall", department: arts_tenant.name, tenant: arts_tenant)
      create(:booking, venue: science_venue, user: science_member, status: :pending)
      create(:booking, venue: arts_venue, user: arts_member, status: :pending)

      log_in_as(staff)
      get bookings_url

      expect(response).to be_successful
      expect(response.body).to include("Science Hall")
      expect(response.body).not_to include("Arts Hall")
    end

    it "sorts bookings by resource asc and desc" do
      science_tenant = create(:tenant, name: "Science Faculty")
      science_member = create(:user, tenant: science_tenant)
      alpha_venue = create(:venue, name: "Alpha Hall", department: science_tenant.name, tenant: science_tenant)
      zulu_venue = create(:venue, name: "Zulu Hall", department: science_tenant.name, tenant: science_tenant)
      create(:booking, venue: zulu_venue, user: science_member, status: :pending)
      create(:booking, venue: alpha_venue, user: science_member, status: :pending)

      get bookings_url, params: { sort: "resource", direction: "asc" }
      expect(response.body.index("Alpha Hall")).to be < response.body.index("Zulu Hall")

      get bookings_url, params: { sort: "resource", direction: "desc" }
      expect(response.body.index("Zulu Hall")).to be < response.body.index("Alpha Hall")
    end
  end

  describe "GET /my" do
    it "allows society members to access my bookings" do
      get my_bookings_path
      expect(response).to be_successful
    end

    it "blocks staff from accessing my bookings" do
      staff = create(:user, :staff, tenant: tenant)
      log_in_as(staff)

      get my_bookings_path

      expect(response).to redirect_to(dashboard_path)
      expect(flash[:alert]).to eq("Only students can access My Bookings.")
    end

    it "blocks admin from accessing my bookings" do
      admin = create(:user, :admin)
      log_in_as(admin)

      get my_bookings_path

      expect(response).to redirect_to(dashboard_path)
      expect(flash[:alert]).to eq("Only students can access My Bookings.")
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      booking = VenueBooking.create! valid_attributes.merge(user: user)
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
      booking = VenueBooking.create! valid_attributes.merge(user: user)
      get edit_booking_url(booking)
      expect(response).to be_successful
    end

    it "prevents staff from editing bookings" do
      booking = VenueBooking.create! valid_attributes.merge(user: user)
      staff = create(:user, :staff, tenant: tenant)
      log_in_as(staff)

      get edit_booking_url(booking)

      expect(response).to redirect_to(bookings_path)
      expect(flash[:alert]).to eq("Staff and admin cannot edit bookings.")
    end

    it "prevents admin from editing bookings" do
      booking = VenueBooking.create! valid_attributes.merge(user: user)
      admin = create(:user, :admin)
      log_in_as(admin)

      get edit_booking_url(booking)

      expect(response).to redirect_to(bookings_path)
      expect(flash[:alert]).to eq("Staff and admin cannot edit bookings.")
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

      it "shows direct validation message without verbose error header" do
        post bookings_url, params: {
          booking: {
            venue_id: venue.id,
            start_time: Time.zone.parse("2026-04-10 10:00:00"),
            end_time: Time.zone.parse("2026-04-10 09:00:00")
          }
        }

        expect(response.body).to include("End time must be after start time")
        expect(response.body).not_to include("error prohibited this booking from being saved")
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
        {
          start_time: Time.zone.parse("2026-04-10 13:00:00"),
          end_time: Time.zone.parse("2026-04-10 14:00:00")
        }
      }

      it "updates the requested booking" do
        booking = VenueBooking.create! valid_attributes.merge(user: user)
        patch booking_url(booking), params: { booking: new_attributes }
        booking.reload
        expect(booking.start_time).to be_within(1.second).of(new_attributes[:start_time])
      end

      it "redirects to the booking" do
        booking = VenueBooking.create! valid_attributes.merge(user: user)
        patch booking_url(booking), params: { booking: new_attributes }
        booking.reload
        expect(response).to redirect_to(booking_url(booking))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        booking = VenueBooking.create! valid_attributes.merge(user: user)
        patch booking_url(booking), params: {
          booking: {
            venue_id: venue.id,
            start_time: "",
            end_time: ""
          }
        }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when current user is staff or admin" do
      it "prevents staff from updating bookings" do
        booking = VenueBooking.create! valid_attributes.merge(user: user)
        staff = create(:user, :staff, tenant: tenant)
        log_in_as(staff)

        patch booking_url(booking), params: { booking: { start_time: Time.zone.parse("2026-04-10 15:00:00") } }

        expect(response).to redirect_to(bookings_path)
        expect(flash[:alert]).to eq("Staff and admin cannot edit bookings.")
      end

      it "prevents admin from updating bookings" do
        booking = VenueBooking.create! valid_attributes.merge(user: user)
        admin = create(:user, :admin)
        log_in_as(admin)

        patch booking_url(booking), params: { booking: { start_time: Time.zone.parse("2026-04-10 15:00:00") } }

        expect(response).to redirect_to(bookings_path)
        expect(flash[:alert]).to eq("Staff and admin cannot edit bookings.")
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested booking" do
      booking = VenueBooking.create! valid_attributes.merge(user: user)
      expect {
        delete booking_url(booking)
      }.to change(Booking, :count).by(-1)
    end

    it "redirects to the bookings list" do
      booking = VenueBooking.create! valid_attributes.merge(user: user)
      delete booking_url(booking)
      expect(response).to redirect_to(bookings_url)
    end
  end

  describe "GET /approval_dashboard" do
    let(:science_tenant) { create(:tenant, name: "Science Faculty") }
    let(:arts_tenant) { create(:tenant, name: "Arts Faculty") }
    let(:staff_user) { create(:user, :staff, tenant: science_tenant) }

    before do
      log_in_as(staff_user)
    end

    it "shows only pending bookings in the staff tenant" do
      scoped_venue = create(:venue, name: "Room 101", department: science_tenant.name, tenant: science_tenant)
      foreign_venue = create(:venue, name: "LT1", department: arts_tenant.name, tenant: arts_tenant)
      create(:booking, venue: scoped_venue, user: create(:user, tenant: science_tenant), status: :pending)
      create(:booking, venue: foreign_venue, user: create(:user, tenant: arts_tenant), status: :pending)

      get approval_dashboard_path

      expect(response).to be_successful
      expect(response.body).to include("Room 101")
      expect(response.body).not_to include("LT1")
    end

    it "keeps legacy venues visible when department matches tenant name" do
      legacy_venue = create(:venue, name: "Legacy Room", department: science_tenant.name, tenant: nil)
      create(:booking, venue: legacy_venue, user: create(:user, tenant: science_tenant), status: :pending)

      get approval_dashboard_path

      expect(response.body).to include("Legacy Room")
    end

    it "sorts approval rows by venue name ascending and descending" do
      zulu_start = 3.days.from_now.change(min: 0, sec: 0)
      alpha_start = 1.day.from_now.change(min: 0, sec: 0)
      create(:booking, venue: create(:venue, name: "Zulu Room", department: science_tenant.name, tenant: science_tenant), user: create(:user, tenant: science_tenant), status: :pending, start_time: zulu_start, end_time: zulu_start + 1.hour)
      create(:booking, venue: create(:venue, name: "Alpha Room", department: science_tenant.name, tenant: science_tenant), user: create(:user, tenant: science_tenant), status: :pending, start_time: alpha_start, end_time: alpha_start + 1.hour)

      get approval_dashboard_path, params: { sort: "venue", direction: "asc" }
      expect(response.body.index("Alpha Room")).to be < response.body.index("Zulu Room")

      get approval_dashboard_path, params: { sort: "venue", direction: "desc" }
      expect(response.body.index("Zulu Room")).to be < response.body.index("Alpha Room")

      get approval_dashboard_path
      expect(response.body.index("Zulu Room")).to be < response.body.index("Alpha Room")
    end
  end

  describe "PATCH /bookings/:id/approve" do
    let(:science_tenant) { create(:tenant, name: "Science Faculty") }
    let(:arts_tenant) { create(:tenant, name: "Arts Faculty") }
    let(:staff_user) { create(:user, :staff, tenant: science_tenant) }

    before do
      log_in_as(staff_user)
    end

    it "allows staff to approve a booking in their tenant" do
      scoped_venue = create(:venue, department: science_tenant.name, tenant: science_tenant)
      booking = create(:booking, venue: scoped_venue, user: create(:user, tenant: science_tenant), status: :pending)

      patch approve_booking_path(booking)

      expect(response).to redirect_to(approval_dashboard_path)
      expect(booking.reload.status).to eq("approved")
    end

    it "rejects approval for bookings outside staff tenant" do
      foreign_venue = create(:venue, department: arts_tenant.name, tenant: arts_tenant)
      booking = create(:booking, venue: foreign_venue, user: create(:user, tenant: arts_tenant), status: :pending)

      patch approve_booking_path(booking)

      expect(response).to redirect_to(approval_dashboard_path)
      expect(booking.reload.status).to eq("pending")
    end
  end

  describe "PATCH /bookings/:id/reject" do
    let(:science_tenant) { create(:tenant, name: "Science Faculty") }
    let(:arts_tenant) { create(:tenant, name: "Arts Faculty") }
    let(:staff_user) { create(:user, :staff, tenant: science_tenant) }

    before do
      log_in_as(staff_user)
    end

    it "allows staff to reject a booking in their tenant and saves reason" do
      scoped_venue = create(:venue, department: science_tenant.name, tenant: science_tenant)
      booking = create(:booking, venue: scoped_venue, user: create(:user, tenant: science_tenant), status: :pending)

      patch reject_booking_path(booking), params: { rejection_reason: "Maintenance" }

      expect(response).to redirect_to(approval_dashboard_path)
      expect(booking.reload.status).to eq("rejected")
      expect(booking.rejection_reason).to eq("Maintenance")
    end

    it "blocks staff from rejecting bookings outside their tenant" do
      foreign_venue = create(:venue, department: arts_tenant.name, tenant: arts_tenant)
      booking = create(:booking, venue: foreign_venue, user: create(:user, tenant: arts_tenant), status: :pending)

      patch reject_booking_path(booking), params: { rejection_reason: "Not allowed" }

      expect(response).to redirect_to(approval_dashboard_path)
      expect(flash[:alert]).to eq("You are not authorized to access this booking.")
      expect(booking.reload.status).to eq("pending")
      expect(booking.rejection_reason).to be_nil
    end
  end

  describe "tenant and ownership hardening" do
    let(:science_tenant) { create(:tenant, name: "Science Faculty") }
    let(:arts_tenant) { create(:tenant, name: "Arts Faculty") }

    it "prevents society members from viewing bookings owned by another user" do
      owner = create(:user, tenant: science_tenant)
      intruder = create(:user, tenant: science_tenant)
      booking = create(:booking, user: owner, venue: create(:venue, tenant: science_tenant, department: science_tenant.name))

      log_in_as(intruder)
      get booking_url(booking)

      expect(response).to redirect_to(my_bookings_path)
      expect(flash[:alert]).to eq("You are not authorized to access this booking.")
    end

    it "prevents users from assigning bookings to venues outside their tenant" do
      member = create(:user, tenant: science_tenant)
      own_venue = create(:venue, tenant: science_tenant, department: science_tenant.name)
      foreign_venue = create(:venue, tenant: arts_tenant, department: arts_tenant.name)
      booking = create(:booking, user: member, venue: own_venue)

      log_in_as(member)
      patch booking_url(booking), params: { booking: { venue_id: foreign_venue.id } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(booking.reload.venue_id).to eq(own_venue.id)
    end
  end

  describe "PATCH /bookings/:id/mark_returned" do
    it "allows users to return approved equipment bookings" do
      equipment = create(:equipment, tenant: tenant)
      booking = create(:equipment_booking, user: user, equipment: equipment, status: :approved)

      patch mark_returned_booking_path(booking)

      expect(response).to redirect_to(my_bookings_path)
      expect(booking.reload.status).to eq("returned")
    end

    it "blocks returning venue bookings" do
      booking = create(:booking, user: user, venue: venue, status: :approved)

      patch mark_returned_booking_path(booking)

      expect(response).to redirect_to(my_bookings_path)
      expect(flash[:alert]).to include("can only be marked as returned")
      expect(booking.reload.status).to eq("approved")
    end

    it "blocks returning equipment bookings that are not approved or borrowed" do
      equipment = create(:equipment, tenant: tenant)
      booking = create(:equipment_booking, user: user, equipment: equipment, status: :pending)

      patch mark_returned_booking_path(booking)

      expect(response).to redirect_to(my_bookings_path)
      expect(flash[:alert]).to include("cannot transition from pending to returned")
      expect(booking.reload.status).to eq("pending")
    end
  end
end
