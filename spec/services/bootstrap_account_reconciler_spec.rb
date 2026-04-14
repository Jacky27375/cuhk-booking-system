require "rails_helper"

RSpec.describe BootstrapAccountReconciler do
  let!(:university_tenant) { create(:tenant, name: "University", slug: "university") }
  let!(:new_asia_tenant) { create(:tenant, name: "New Asia College", slug: "new-asia-college") }
  let!(:lee_woo_sing_tenant) { create(:tenant, name: "Lee Woo Sing College", slug: "lee-woo-sing-college") }

  let(:tenants) do
    {
      "University" => university_tenant,
      "New Asia College" => new_asia_tenant,
      "Lee Woo Sing College" => lee_woo_sing_tenant
    }
  end

  let(:root_staff_emails) do
    {
      "University" => "staff_root_university@link.cuhk.edu.hk",
      "New Asia College" => "staff_root_newasia@link.cuhk.edu.hk",
      "Lee Woo Sing College" => "staff_root_leewoosing@link.cuhk.edu.hk"
    }
  end

  let(:bootstrap_password) { "BootstrapPass1!" }

  describe "#call" do
    it "reconciles stale bootstrap admin/root accounts and resets canonical credentials" do
      canonical_admin = create(
        :user,
        :admin,
        tenant: university_tenant,
        email: "admin@link.cuhk.edu.hk",
        password: "LegacyPass1!",
        password_confirmation: "LegacyPass1!"
      )
      stale_admin = create(:user, :admin, tenant: university_tenant, email: "admin_legacy@link.cuhk.edu.hk")

      canonical_new_asia_root = create(
        :user,
        :root_account,
        tenant: new_asia_tenant,
        email: "staff_root_newasia@link.cuhk.edu.hk",
        password: "LegacyPass1!",
        password_confirmation: "LegacyPass1!"
      )
      stale_lee_root = create(
        :user,
        :root_account,
        tenant: lee_woo_sing_tenant,
        email: "staff_root_leewoosin@link.cuhk.edu.hk"
      )
      stale_university_root = create(
        :user,
        :root_account,
        tenant: university_tenant,
        email: "staff_root_university_legacy@link.cuhk.edu.hk"
      )

      lee_venue = create(:venue, tenant: lee_woo_sing_tenant, department: lee_woo_sing_tenant.name)
      stale_booking = create(:booking, user: stale_lee_root, venue: lee_venue)
      university_venue = create(:venue, tenant: university_tenant, department: university_tenant.name)
      stale_university_booking = create(:booking, user: stale_university_root, venue: university_venue)
      stale_api_key = create(:api_key, user: stale_lee_root)
      stale_request = create(:venue_request, requester: stale_lee_root, tenant: lee_woo_sing_tenant)
      stale_root_step = create(:approval_step, actor: stale_lee_root)

      requester = create(:user, :staff, tenant: new_asia_tenant)
      reviewed_request = create(
        :venue_request,
        requester: requester,
        tenant: new_asia_tenant,
        status: :approved,
        reviewed_by: stale_admin,
        reviewed_at: Time.current
      )
      stale_admin_step = create(:approval_step, actor: stale_admin)

      result = described_class.new(
        tenants: tenants,
        root_staff_emails: root_staff_emails,
        bootstrap_password: bootstrap_password,
        reset_passwords: true,
        reconcile_obsolete_accounts: true
      ).call

      canonical_lee_root = User.find_by!(email: "staff_root_leewoosing@link.cuhk.edu.hk")
      canonical_university_root = User.find_by!(email: "staff_root_university@link.cuhk.edu.hk")

      expect(result[:admin]).to eq(canonical_admin)
      expect(result[:root_staff_users].keys).to contain_exactly("University", "New Asia College", "Lee Woo Sing College")
      expect(result[:root_staff_users]["Lee Woo Sing College"]).to eq(canonical_lee_root)
      expect(result[:root_staff_users]["University"]).to eq(canonical_university_root)

      expect(canonical_admin.reload.authenticate(bootstrap_password)).to eq(canonical_admin)
      expect(canonical_new_asia_root.reload.authenticate(bootstrap_password)).to eq(canonical_new_asia_root)
      expect(canonical_lee_root.authenticate(bootstrap_password)).to eq(canonical_lee_root)
      expect(canonical_university_root.authenticate(bootstrap_password)).to eq(canonical_university_root)

      expect(User.exists?(stale_admin.id)).to be(false)
      expect(User.exists?(stale_lee_root.id)).to be(false)
      expect(User.exists?(stale_university_root.id)).to be(false)

      expect(stale_booking.reload.user_id).to eq(canonical_lee_root.id)
      expect(stale_university_booking.reload.user_id).to eq(canonical_university_root.id)
      expect(stale_api_key.reload.user_id).to eq(canonical_lee_root.id)
      expect(stale_request.reload.requester_id).to eq(canonical_lee_root.id)
      expect(stale_root_step.reload.actor_id).to eq(canonical_lee_root.id)
      expect(reviewed_request.reload.reviewed_by_id).to eq(canonical_admin.id)
      expect(stale_admin_step.reload.actor_id).to eq(canonical_admin.id)
    end

    it "does not reset existing canonical passwords when reset is disabled" do
      admin = create(
        :user,
        :admin,
        tenant: university_tenant,
        email: "admin@link.cuhk.edu.hk",
        password: "KeepCurrent1!",
        password_confirmation: "KeepCurrent1!"
      )
      new_asia_root = create(
        :user,
        :root_account,
        tenant: new_asia_tenant,
        email: "staff_root_newasia@link.cuhk.edu.hk",
        password: "KeepCurrent1!",
        password_confirmation: "KeepCurrent1!"
      )
      university_root = create(
        :user,
        :root_account,
        tenant: university_tenant,
        email: "staff_root_university@link.cuhk.edu.hk",
        password: "KeepCurrent1!",
        password_confirmation: "KeepCurrent1!"
      )

      described_class.new(
        tenants: tenants,
        root_staff_emails: root_staff_emails,
        bootstrap_password: bootstrap_password,
        reset_passwords: false,
        reconcile_obsolete_accounts: false
      ).call

      expect(admin.reload.authenticate("KeepCurrent1!")).to eq(admin)
      expect(new_asia_root.reload.authenticate("KeepCurrent1!")).to eq(new_asia_root)
      expect(university_root.reload.authenticate("KeepCurrent1!")).to eq(university_root)
      expect(admin.authenticate(bootstrap_password)).to be_falsey
      expect(new_asia_root.authenticate(bootstrap_password)).to be_falsey
      expect(university_root.authenticate(bootstrap_password)).to be_falsey
    end
  end
end
