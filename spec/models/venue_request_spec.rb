require 'rails_helper'

RSpec.describe VenueRequest, type: :model do
  let(:tenant) { create(:tenant) }
  let(:staff_user) { create(:user, :staff, tenant: tenant) }
  let(:admin_user) { create(:user, :admin) }
  let(:student_user) { create(:user, :student, tenant: tenant) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      request = build(:venue_request, requester: staff_user, tenant: tenant)
      expect(request).to be_valid
    end

    it 'requires a venue name' do
      request = build(:venue_request, requester: staff_user, tenant: tenant, venue_name: nil)
      expect(request).not_to be_valid
      expect(request.errors[:venue_name]).to include("can't be blank")
    end

    it 'requires requester to be staff' do
      request = build(:venue_request, requester: student_user, tenant: tenant)
      expect(request).not_to be_valid
      expect(request.errors[:requester]).to include("must be staff")
    end
  end

  describe '#approve!' do
    it 'creates a venue and marks request as approved' do
      request = create(:venue_request, requester: staff_user, tenant: tenant, venue_name: 'New Hall')

      expect {
        request.approve!(admin_user)
      }.to change(Venue, :count).by(1)

      expect(request.reload.approved?).to be(true)
      expect(request.reviewed_by).to eq(admin_user)

      venue = Venue.last
      expect(venue.name).to eq('New Hall')
      expect(venue.tenant).to eq(tenant)
    end
  end

  describe '#reject!' do
    it 'marks request as rejected with reason' do
      request = create(:venue_request, requester: staff_user, tenant: tenant)
      request.reject!(admin_user, reason: 'Duplicate')

      expect(request.reload.rejected?).to be(true)
      expect(request.rejection_reason).to eq('Duplicate')
      expect(request.reviewed_by).to eq(admin_user)
    end
  end
end
