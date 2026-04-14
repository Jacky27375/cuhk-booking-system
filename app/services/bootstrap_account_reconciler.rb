class BootstrapAccountReconciler
  ADMIN_EMAIL = "admin@link.cuhk.edu.hk".freeze

  def initialize(tenants:, root_staff_emails:, bootstrap_password:, reset_passwords:, reconcile_obsolete_accounts:)
    @tenants = tenants
    @root_staff_emails = root_staff_emails
    @bootstrap_password = bootstrap_password
    @reset_passwords = reset_passwords
    @reconcile_obsolete_accounts = reconcile_obsolete_accounts
  end

  def call
    admin = ensure_admin_account!
    root_staff_users = ensure_root_staff_accounts!

    reconcile_obsolete_accounts!(admin:, root_staff_users:) if @reconcile_obsolete_accounts

    { admin:, root_staff_users: }
  end

  private

  attr_reader :tenants, :root_staff_emails, :bootstrap_password

  def ensure_admin_account!
    admin = User.find_or_initialize_by(email: ADMIN_EMAIL)
    admin.role = :admin
    admin.is_root_account = false
    admin.tenant = tenants.fetch("University")
    assign_password_if_needed(admin)
    admin.save!
    admin
  end

  def ensure_root_staff_accounts!
    root_staff_emails.each_with_object({}) do |(college_name, email), memo|
      user = User.find_or_initialize_by(email: email)
      user.role = :staff
      user.is_root_account = true
      user.tenant = tenants.fetch(college_name)
      assign_password_if_needed(user)
      user.save!
      memo[college_name] = user
    end
  end

  def assign_password_if_needed(user)
    return unless @reset_passwords || user.new_record? || user.password_digest.blank?

    user.password = bootstrap_password
    user.password_confirmation = bootstrap_password
  end

  def reconcile_obsolete_accounts!(admin:, root_staff_users:)
    root_staff_by_tenant_id = root_staff_users.values.index_by(&:tenant_id)

    stale_bootstrap_accounts(root_staff_users).each do |stale_user|
      replacement_user = replacement_for(stale_user, admin:, root_staff_by_tenant_id:)
      reassign_dependencies!(from_user: stale_user, to_user: replacement_user) if replacement_user
      stale_user.destroy!
    end
  end

  def stale_bootstrap_accounts(root_staff_users)
    stale_admins = User.admin.where.not(email: ADMIN_EMAIL)
    canonical_root_emails = root_staff_users.values.map(&:email)
    stale_root_staff = User.staff.root_accounts.where.not(email: canonical_root_emails)

    (stale_admins + stale_root_staff).uniq
  end

  def replacement_for(stale_user, admin:, root_staff_by_tenant_id:)
    return admin if stale_user.admin?
    return root_staff_by_tenant_id[stale_user.tenant_id] if stale_user.root_staff_account?

    nil
  end

  def reassign_dependencies!(from_user:, to_user:)
    return if from_user.id == to_user.id

    Booking.where(user_id: from_user.id).update_all(user_id: to_user.id)
    ApiKey.where(user_id: from_user.id).update_all(user_id: to_user.id)
    ApprovalStep.where(actor_id: from_user.id).update_all(actor_id: to_user.id)
    VenueRequest.where(requester_id: from_user.id).update_all(requester_id: to_user.id)
    VenueRequest.where(reviewed_by_id: from_user.id).update_all(reviewed_by_id: to_user.id)
  end
end
