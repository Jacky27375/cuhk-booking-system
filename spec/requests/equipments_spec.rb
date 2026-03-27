require 'rails_helper'

RSpec.describe 'Equipments', type: :request do
  let!(:tenant_a) { create(:tenant) }
  let!(:tenant_b) { create(:tenant) }

  let!(:staff_user) { create(:user, :staff, tenant: tenant_a) }
  let!(:admin_user) { create(:user, :admin, tenant: tenant_a) }
  let!(:member_user) { create(:user, :society_member, tenant: tenant_a) }

  let!(:tenant_a_equipment) { create(:equipment, tenant: tenant_a, name: 'Projector', quantity: 5) }
  let!(:tenant_b_equipment) { create(:equipment, tenant: tenant_b, name: 'Speaker', quantity: 3) }

  describe 'GET /equipments' do
    it 'redirects unauthenticated users to login' do
      get equipments_path
      expect(response).to redirect_to(login_path)
    end

    it 'shows only current tenant equipment for authenticated users' do
      log_in_as(staff_user)
      get equipments_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Projector')
      expect(response.body).not_to include('Speaker')
    end
  end

  describe 'GET /equipments/:id' do
    it 'allows viewing equipment in the same tenant' do
      log_in_as(member_user)
      get equipment_path(tenant_a_equipment)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Projector')
    end

    it 'does not allow viewing equipment from another tenant' do
      log_in_as(member_user)
      get equipment_path(tenant_b_equipment)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /equipments' do
    let(:valid_params) { { equipment: { name: 'Microphone', quantity: 10 } } }

    it 'allows staff to create equipment' do
      log_in_as(staff_user)

      expect do
        post equipments_path, params: valid_params
      end.to change(Equipment, :count).by(1)

      expect(response).to redirect_to(equipment_path(Equipment.last))
      expect(Equipment.last.tenant_id).to eq(tenant_a.id)
    end

    it 'allows admin to create equipment' do
      log_in_as(admin_user)

      expect do
        post equipments_path, params: valid_params
      end.to change(Equipment, :count).by(1)

      expect(response).to redirect_to(equipment_path(Equipment.last))
    end

    it 'denies society members' do
      log_in_as(member_user)

      expect do
        post equipments_path, params: valid_params
      end.not_to change(Equipment, :count)

      expect(response).to redirect_to(equipments_path)
      follow_redirect!
      expect(response.body).to include('You are not authorized')
    end
  end

  describe 'PATCH /equipments/:id' do
    it 'allows staff to update equipment in same tenant' do
      log_in_as(staff_user)
      patch equipment_path(tenant_a_equipment), params: { equipment: { quantity: 8 } }

      expect(response).to redirect_to(equipment_path(tenant_a_equipment))
      expect(tenant_a_equipment.reload.quantity).to eq(8)
    end

    it 'denies society members from updating equipment' do
      log_in_as(member_user)
      patch equipment_path(tenant_a_equipment), params: { equipment: { quantity: 8 } }

      expect(response).to redirect_to(equipments_path)
      expect(tenant_a_equipment.reload.quantity).to eq(5)
    end
  end

  describe 'DELETE /equipments/:id' do
    it 'allows admin to delete equipment' do
      log_in_as(admin_user)

      expect do
        delete equipment_path(tenant_a_equipment)
      end.to change(Equipment, :count).by(-1)

      expect(response).to redirect_to(equipments_path)
    end

    it 'denies society members from deleting equipment' do
      log_in_as(member_user)

      expect do
        delete equipment_path(tenant_a_equipment)
      end.not_to change(Equipment, :count)

      expect(response).to redirect_to(equipments_path)
    end
  end
end
