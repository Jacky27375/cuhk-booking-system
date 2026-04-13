require 'rails_helper'
require 'nokogiri'

RSpec.describe "/bookings", type: :request do
  let(:tenant) { create(:tenant, name: "University", slug: "university") }
  let(:user) { FactoryBot.create(:user, tenant: tenant) }
  let(:venue) { FactoryBot.create(:venue, tenant: tenant, department: tenant.name) }

  let(:valid_attributes) {
    {
      venue_id: venue.id,
      start_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 10:00:00'),
      end_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 12:00:00')
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

    it "shows compact booking controls and a readable timetable time column" do
      booking_date = 5.days.from_now.to_date

      get new_booking_url, params: { venue_id: venue.id, booking_date: booking_date.to_s }

      document = Nokogiri::HTML(response.body)
      booking_date_input = document.at_css('input#booking_date')

      expect(response.body).to include('booking-time-fields')
      expect(response.body).to include('Time Slot')
      expect(response.body).not_to include('Selected date:')
      expect(booking_date_input).not_to be_nil
      expect(booking_date_input['value']).to eq(booking_date.to_s)
    end

    it "excludes unavailable start slots" do
      booking_date = 5.days.from_now.to_date
      other_user = create(:user, tenant: tenant, email: "other-student@link.cuhk.edu.hk")
      create(
        :booking,
        venue: venue,
        user: other_user,
        start_time: Time.zone.parse("#{booking_date} 08:00:00"),
        end_time: Time.zone.parse("#{booking_date} 10:00:00")
      )

      get new_booking_url, params: { venue_id: venue.id, booking_date: booking_date.to_s }

      document = Nokogiri::HTML(response.body)
      start_options = document.css('select#booking_start_slot option').map { |node| node['value'] }.reject(&:blank?)

      expect(start_options).not_to include('08:00', '09:00')
      expect(start_options).to include('10:00')
    end

    it "shows no end slot options until a start slot is chosen" do
      booking_date = 5.days.from_now.to_date

      get new_booking_url, params: { venue_id: venue.id, booking_date: booking_date.to_s }

      document = Nokogiri::HTML(response.body)
      end_options = document.css('select#booking_end_slot option').map { |node| node['value'] }.reject(&:blank?)

      expect(end_options).to be_empty
    end

    it "limits end slot options to valid non-overlapping ranges up to 4 hours" do
      booking_date = 5.days.from_now.to_date
      other_user = create(:user, tenant: tenant, email: "another-student@link.cuhk.edu.hk")
      create(
        :booking,
        venue: venue,
        user: other_user,
        start_time: Time.zone.parse("#{booking_date} 12:00:00"),
        end_time: Time.zone.parse("#{booking_date} 13:00:00")
      )

      get new_booking_url, params: {
        venue_id: venue.id,
        booking_date: booking_date.to_s,
        booking: { start_slot: '10:00' }
      }

      document = Nokogiri::HTML(response.body)
      end_options = document.css('select#booking_end_slot option').map { |node| node['value'] }.reject(&:blank?)

      expect(end_options).to contain_exactly('11:00', '12:00')
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
            start_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 10:00:00'),
            end_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 09:00:00')
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

  describe "POST /confirm" do
    it "shows validation error and does not highlight selected timetable slots for invalid duration" do
      booking_date = 5.days.from_now.to_date.strftime('%Y-%m-%d')

      post confirm_bookings_path, params: {
        booking: {
          venue_id: venue.id,
          booking_date: booking_date,
          start_slot: '08:00',
          end_slot: '13:00'
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Booking duration cannot exceed 4 hours')
      expect(response.body).not_to match(/timetable-slot-selected[^>]*>\s*08:00 - 09:00/m)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          start_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 13:00:00'),
          end_time: Time.zone.parse(5.days.from_now.strftime('%Y-%m-%d') + ' 14:00:00')
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

    it "shows bookings awaiting approval in the staff tenant" do
      scoped_venue = create(:venue, name: "Room 101", department: science_tenant.name, tenant: science_tenant)
      scoped_under_review_venue = create(:venue, name: "Room 102", department: science_tenant.name, tenant: science_tenant)
      scoped_approved_venue = create(:venue, name: "Room 103", department: science_tenant.name, tenant: science_tenant)
      foreign_venue = create(:venue, name: "LT1", department: arts_tenant.name, tenant: arts_tenant)
      create(:booking, venue: scoped_venue, user: create(:user, tenant: science_tenant), status: :pending)
      create(:booking, venue: scoped_under_review_venue, user: create(:user, tenant: science_tenant), status: :under_review)
      create(:booking, venue: scoped_approved_venue, user: create(:user, tenant: science_tenant), status: :approved)
      create(:booking, venue: foreign_venue, user: create(:user, tenant: arts_tenant), status: :pending)

      get approval_dashboard_path

      expect(response).to be_successful
      expect(response.body).to include("Room 101")
      expect(response.body).to include("Room 102")
      expect(response.body).not_to include("Room 103")
      expect(response.body).not_to include("LT1")
    end

    it "keeps legacy venues visible when department matches tenant name" do
      legacy_venue = create(:venue, name: "Legacy Room", department: science_tenant.name, tenant: nil)
      create(:booking, venue: legacy_venue, user: create(:user, tenant: science_tenant), status: :pending)

      get approval_dashboard_path

      expect(response.body).to include("Legacy Room")
    end

    it "sorts approval rows by venue name ascending and descending" do
      zulu_start = 8.days.from_now.change(hour: 10, min: 0, sec: 0)
      alpha_start = 7.days.from_now.change(hour: 10, min: 0, sec: 0)
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
      expect(booking.approval_steps.count).to eq(1)
      expect(booking.approval_steps.last.action).to eq("approve")
    end

    it "allows staff to approve equipment booking even when legacy dates are invalid" do
      equipment = create(:equipment, tenant: science_tenant)
      booking = build(:equipment_booking,
                      user: create(:user, tenant: science_tenant),
                      equipment: equipment,
                      status: :pending,
                      start_date: 1.day.from_now.to_date,
                      end_date: Date.current)
      booking.save!(validate: false)

      patch approve_booking_path(booking)

      expect(response).to redirect_to(approval_dashboard_path)
      expect(booking.reload.status).to eq("approved")
      expect(booking.approval_steps.last.action).to eq("approve")
    end

    it "rejects approval for bookings outside staff tenant" do
      foreign_venue = create(:venue, department: arts_tenant.name, tenant: arts_tenant)
      booking = create(:booking, venue: foreign_venue, user: create(:user, tenant: arts_tenant), status: :pending)

      patch approve_booking_path(booking)

      expect(response).to redirect_to(approval_dashboard_path)
      expect(booking.reload.status).to eq("pending")
    end

    context "when tenant uses two-step approval" do
      before do
        science_tenant.update!(approval_mode: :two_step)
      end

      it "moves pending bookings to under_review on first approval" do
        scoped_venue = create(:venue, department: science_tenant.name, tenant: science_tenant)
        booking = create(:booking, venue: scoped_venue, user: create(:user, tenant: science_tenant), status: :pending)

        patch approve_booking_path(booking)

        expect(response).to redirect_to(approval_dashboard_path)
        expect(booking.reload.status).to eq("under_review")
        expect(booking.approval_steps.count).to eq(1)
        expect(booking.approval_steps.last.action).to eq("start_review")
      end

      it "requires a second approval to reach approved status" do
        scoped_venue = create(:venue, department: science_tenant.name, tenant: science_tenant)
        booking = create(:booking, venue: scoped_venue, user: create(:user, tenant: science_tenant), status: :pending)

        patch approve_booking_path(booking)
        patch approve_booking_path(booking)

        expect(booking.reload.status).to eq("approved")
        expect(booking.approval_steps.pluck(:action)).to eq(%w[start_review approve])
      end
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
      expect(booking.approval_steps.count).to eq(1)
      expect(booking.approval_steps.last.action).to eq("reject")
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

    it "allows rejecting bookings in under_review state" do
      scoped_venue = create(:venue, department: science_tenant.name, tenant: science_tenant)
      booking = create(:booking, venue: scoped_venue, user: create(:user, tenant: science_tenant), status: :under_review)

      patch reject_booking_path(booking), params: { rejection_reason: "No staff available" }

      expect(response).to redirect_to(approval_dashboard_path)
      expect(booking.reload.status).to eq("rejected")
      expect(booking.rejection_reason).to eq("No staff available")
    end
  end

  describe "PATCH /bookings/:id/cancel" do
    let(:owner) { create(:user, tenant: tenant) }

    before do
      log_in_as(owner)
    end

    it "allows owner to cancel an eligible booking" do
      booking = create(:booking,
                       user: owner,
                       venue: venue,
                       status: :pending,
                       start_time: 7.days.from_now.change(hour: 10, min: 0),
                       end_time: 7.days.from_now.change(hour: 12, min: 0))

      patch cancel_booking_path(booking)

      expect(response).to redirect_to(my_bookings_path)
      expect(booking.reload.status).to eq("cancelled")
      expect(booking.approval_steps.count).to eq(1)
      expect(booking.approval_steps.last.action).to eq("cancel")
    end

    it "blocks owner from cancelling non-cancellable bookings" do
      equipment = create(:equipment, tenant: tenant)
      booking = create(:equipment_booking,
                       user: owner,
                       equipment: equipment,
                       status: :returned,
                       start_date: 7.days.from_now.to_date,
                       end_date: 8.days.from_now.to_date)

      patch cancel_booking_path(booking)

      expect(response).to redirect_to(my_bookings_path)
      expect(flash[:alert]).to eq("This booking cannot be cancelled.")
      expect(booking.reload.status).to eq("returned")
    end

    it "blocks cancelling another user's booking" do
      other_user = create(:user, tenant: tenant)
      booking = create(:booking,
                       user: other_user,
                       venue: venue,
                       status: :pending,
                       start_time: 7.days.from_now.change(hour: 10, min: 0),
                       end_time: 7.days.from_now.change(hour: 12, min: 0))

      patch cancel_booking_path(booking)

      expect(response).to redirect_to(my_bookings_path)
      expect(flash[:alert]).to eq("You are not authorized to access this booking.")
      expect(booking.reload.status).to eq("pending")
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
    it "blocks students from marking equipment as returned" do
      equipment = create(:equipment, tenant: tenant)
      booking = create(:equipment_booking, user: user, equipment: equipment, status: :approved)

      patch mark_returned_booking_path(booking)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      expect(booking.reload.status).to eq("approved")
    end

    it "allows admins to return approved equipment bookings" do
      admin = create(:user, :admin)
      equipment = create(:equipment, tenant: tenant)
      booking = create(:equipment_booking, user: user, equipment: equipment, status: :approved)
      log_in_as(admin)

      patch mark_returned_booking_path(booking)

      expect(response).to redirect_to(bookings_path)
      expect(booking.reload.status).to eq("returned")
    end

    it "allows staff to return approved equipment bookings in their tenant" do
      staff = create(:user, :staff, tenant: tenant)
      equipment = create(:equipment, tenant: tenant)
      booking = create(:equipment_booking, user: user, equipment: equipment, status: :approved)
      log_in_as(staff)

      patch mark_returned_booking_path(booking)

      expect(response).to redirect_to(bookings_path)
      expect(booking.reload.status).to eq("returned")
    end

    it "blocks admins returning venue bookings" do
      admin = create(:user, :admin)
      booking = create(:booking, user: user, venue: venue, status: :approved)
      log_in_as(admin)

      patch mark_returned_booking_path(booking)

      expect(response).to redirect_to(bookings_path)
      expect(flash[:alert]).to include("can only be marked as returned")
      expect(booking.reload.status).to eq("approved")
    end

    it "blocks admins returning equipment bookings that are not approved" do
      admin = create(:user, :admin)
      equipment = create(:equipment, tenant: tenant)
      booking = create(:equipment_booking, user: user, equipment: equipment, status: :pending)
      log_in_as(admin)

      patch mark_returned_booking_path(booking)

      expect(response).to redirect_to(bookings_path)
      expect(flash[:alert]).to include("cannot transition from pending to returned")
      expect(booking.reload.status).to eq("pending")
    end

    it "blocks admins returning borrowed equipment bookings" do
      admin = create(:user, :admin)
      equipment = create(:equipment, tenant: tenant)
      booking = create(:equipment_booking, user: user, equipment: equipment, status: :borrowed)
      log_in_as(admin)

      patch mark_returned_booking_path(booking)

      expect(response).to redirect_to(bookings_path)
      expect(flash[:alert]).to include("cannot transition from borrowed to returned")
      expect(booking.reload.status).to eq("borrowed")
    end
  end
end
