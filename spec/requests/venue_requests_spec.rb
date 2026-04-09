require 'rails_helper'

RSpec.describe 'Venue Requests', type: :request do
  let!(:tenant) { create(:tenant) }
  let!(:staff_user) { create(:user, :staff, tenant: tenant) }
  let!(:admin_user) { create(:user, :admin) }
  let!(:student_user) { create(:user, :student, tenant: tenant) }

  describe 'GET /venue_requests' do
    it 'allows staff access' do
      log_in_as(staff_user)
      get venue_requests_path
      expect(response).to have_http_status(:ok)
    end

    it 'allows admin access' do
      create(:venue_request, requester: staff_user, tenant: tenant)
      log_in_as(admin_user)
      get venue_requests_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Reviewed By')
      expect(response.body).to include('Reviewed At')
      expect(response.body).to include('Rejection Reason')
    end

    it 'denies student access' do
      log_in_as(student_user)
      get venue_requests_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'POST /venue_requests' do
    let(:valid_params) { { venue_request: { venue_name: 'New Room 101', description: 'A nice room' } } }

    it 'allows staff to submit a venue request' do
      log_in_as(staff_user)

      expect {
        post venue_requests_path, params: valid_params
      }.to change(VenueRequest, :count).by(1)

      request = VenueRequest.last
      expect(request.requester).to eq(staff_user)
      expect(request.tenant).to eq(tenant)
      expect(request.pending?).to be(true)
      expect(response).to redirect_to(venue_requests_path)
    end

    it 'blocks admin from creating venue requests' do
      log_in_as(admin_user)

      expect {
        post venue_requests_path, params: valid_params
      }.not_to change(VenueRequest, :count)

      expect(response).to redirect_to(venue_requests_path)
      expect(flash[:alert]).to eq('Only staff can submit venue requests.')
    end
  end

  describe 'PATCH /venue_requests/:id/approve' do
    let!(:venue_request) { create(:venue_request, requester: staff_user, tenant: tenant) }

    it 'allows admin to approve and creates a venue' do
      log_in_as(admin_user)

      expect {
        patch approve_venue_request_path(venue_request)
      }.to change(Venue, :count).by(1)

      venue_request.reload
      expect(venue_request.approved?).to be(true)
      expect(venue_request.reviewed_by).to eq(admin_user)
      expect(response).to redirect_to(venue_requests_path)
    end

    it 'denies staff from approving' do
      log_in_as(staff_user)

      expect {
        patch approve_venue_request_path(venue_request)
      }.not_to change(Venue, :count)

      expect(response).to redirect_to(root_path)
    end

    it 'does not re-approve an already reviewed request' do
      log_in_as(admin_user)
      patch approve_venue_request_path(venue_request)
      venue_request.reload

      expect {
        patch approve_venue_request_path(venue_request)
      }.not_to change(Venue, :count)

      expect(response).to redirect_to(venue_requests_path)
      expect(flash[:alert]).to eq('Only pending requests can be approved.')
    end
  end

  describe 'PATCH /venue_requests/:id/reject' do
    let!(:venue_request) { create(:venue_request, requester: staff_user, tenant: tenant) }

    it 'allows admin to reject with reason' do
      log_in_as(admin_user)
      patch reject_venue_request_path(venue_request), params: { rejection_reason: 'Not needed' }

      venue_request.reload
      expect(venue_request.rejected?).to be(true)
      expect(venue_request.rejection_reason).to eq('Not needed')
      expect(response).to redirect_to(venue_requests_path)
    end

    it 'requires a rejection reason' do
      log_in_as(admin_user)

      patch reject_venue_request_path(venue_request), params: { rejection_reason: '   ' }

      expect(response).to redirect_to(venue_requests_path)
      expect(flash[:alert]).to eq('Rejection reason cannot be blank.')
      expect(venue_request.reload.status).to eq('pending')
    end
  end
end
