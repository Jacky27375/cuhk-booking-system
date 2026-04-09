class DefaultIdentityBootstrap
  DEFAULT_PASSWORD = "Password1!"
  ADMIN_EMAIL = "admin@link.cuhk.edu.hk"

  COLLEGE_TENANTS = [
    { name: "Chung Chi College", slug: "chung-chi-college", description: "Chung Chi College facilities" },
    { name: "New Asia College", slug: "new-asia-college", description: "New Asia College facilities" },
    { name: "United College", slug: "united-college", description: "United College facilities" },
    { name: "Shaw College", slug: "shaw-college", description: "Shaw College facilities" },
    { name: "Morningside College", slug: "morningside-college", description: "Morningside College facilities" },
    { name: "S.H. Ho College", slug: "s-h-ho-college", description: "S.H. Ho College facilities" },
    { name: "CW Chu College", slug: "cw-chu-college", description: "CW Chu College facilities" },
    { name: "Wu Yee Sun College", slug: "wu-yee-sun-college", description: "Wu Yee Sun College facilities" },
    { name: "Lee Woo Sing College", slug: "lee-woo-sing-college", description: "Lee Woo Sing College facilities" }
  ].freeze

  UNIVERSITY_TENANT = {
    name: "University",
    slug: "university",
    description: "University shared facilities"
  }.freeze

  ROOT_STAFF_EMAILS = {
    "Chung Chi College" => "staff_root_chungchi@link.cuhk.edu.hk",
    "New Asia College" => "staff_root_newasia@link.cuhk.edu.hk",
    "United College" => "staff_root_united@link.cuhk.edu.hk",
    "Shaw College" => "staff_root_shaw@link.cuhk.edu.hk",
    "Morningside College" => "staff_root_morningside@link.cuhk.edu.hk",
    "S.H. Ho College" => "staff_root_shho@link.cuhk.edu.hk",
    "CW Chu College" => "staff_root_cwchu@link.cuhk.edu.hk",
    "Wu Yee Sun College" => "staff_root_wuyeesun@link.cuhk.edu.hk",
    "Lee Woo Sing College" => "staff_root_leewoosin@link.cuhk.edu.hk"
  }.freeze

  class << self
    def ensure_college_tenants!
      ensure_tenants!
    end

    def ensure_seed_account_for!(email)
      normalized_email = email.to_s.strip.downcase
      return if normalized_email.blank?

      if normalized_email == ADMIN_EMAIL
        tenants_by_name = ensure_tenants!
        ensure_admin_account!(tenants_by_name.fetch(UNIVERSITY_TENANT[:name]))
        return
      end

      college_name = ROOT_STAFF_EMAILS.key(normalized_email)
      return if college_name.blank?

      tenants_by_name = ensure_tenants!
      ensure_root_staff_account!(
        email: normalized_email,
        tenant: tenants_by_name.fetch(college_name)
      )
    end

    private

    def ensure_tenants!
      tenants_by_name = {}

      COLLEGE_TENANTS.each do |tenant_data|
        tenant = Tenant.find_or_create_by!(slug: tenant_data[:slug]) do |record|
          record.name = tenant_data[:name]
          record.description = tenant_data[:description]
        end
        tenants_by_name[tenant.name] = tenant
      end

      university = Tenant.find_or_create_by!(slug: UNIVERSITY_TENANT[:slug]) do |record|
        record.name = UNIVERSITY_TENANT[:name]
        record.description = UNIVERSITY_TENANT[:description]
      end
      tenants_by_name[university.name] = university

      tenants_by_name
    end

    def ensure_admin_account!(tenant)
      User.find_or_create_by!(email: ADMIN_EMAIL) do |user|
        user.password = DEFAULT_PASSWORD
        user.password_confirmation = DEFAULT_PASSWORD
        user.role = :admin
        user.tenant = tenant
      end
    end

    def ensure_root_staff_account!(email:, tenant:)
      User.find_or_create_by!(email: email) do |user|
        user.password = DEFAULT_PASSWORD
        user.password_confirmation = DEFAULT_PASSWORD
        user.role = :staff
        user.is_root_account = true
        user.tenant = tenant
      end
    end
  end
end
