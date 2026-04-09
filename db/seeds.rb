# Seed data for CUHK Booking System

# 9 CUHK Colleges + University (for shared resources)
colleges = [
  { name: "Chung Chi College", slug: "chung-chi-college" },
  { name: "New Asia College", slug: "new-asia-college" },
  { name: "United College", slug: "united-college" },
  { name: "Shaw College", slug: "shaw-college" },
  { name: "Morningside College", slug: "morningside-college" },
  { name: "S.H. Ho College", slug: "s-h-ho-college" },
  { name: "CW Chu College", slug: "cw-chu-college" },
  { name: "Wu Yee Sun College", slug: "wu-yee-sun-college" },
  { name: "Lee Woo Sing College", slug: "lee-woo-sing-college" }
]

# College -> Room mapping from College List
college_rooms = {
  "Chung Chi College" => "Room 1",
  "New Asia College" => "Room 2",
  "United College" => "Room 3",
  "Shaw College" => "Room 4",
  "Morningside College" => "Room 5",
  "S.H. Ho College" => "Room 6",
  "CW Chu College" => "Room 7",
  "Wu Yee Sun College" => "Room 8",
  "Lee Woo Sing College" => "Room 9"
}

# Root staff account email mapping
root_staff_emails = {
  "Chung Chi College" => "staff_root_chungchi@link.cuhk.edu.hk",
  "New Asia College" => "staff_root_newasia@link.cuhk.edu.hk",
  "United College" => "staff_root_united@link.cuhk.edu.hk",
  "Shaw College" => "staff_root_shaw@link.cuhk.edu.hk",
  "Morningside College" => "staff_root_morningside@link.cuhk.edu.hk",
  "S.H. Ho College" => "staff_root_shho@link.cuhk.edu.hk",
  "CW Chu College" => "staff_root_cwchu@link.cuhk.edu.hk",
  "Wu Yee Sun College" => "staff_root_wuyeesun@link.cuhk.edu.hk",
  "Lee Woo Sing College" => "staff_root_leewoosin@link.cuhk.edu.hk"
}

unless Rails.env.production?
  puts "Creating tenants..."

  # Create college tenants
  tenants = {}
  colleges.each do |college|
    tenants[college[:name]] = Tenant.find_or_create_by!(slug: college[:slug]) do |t|
      t.name = college[:name]
      t.description = "#{college[:name]} facilities"
    end
  end

  # Create University tenant (for shared resources)
  tenants["University"] = Tenant.find_or_create_by!(slug: "university") do |t|
    t.name = "University"
    t.description = "University shared facilities"
  end

  # Create venues: Room 1-9 (one per college) + University Room (shared)
  puts "Creating venues..."
  college_rooms.each do |college_name, room_name|
    Venue.find_or_create_by!(name: room_name) do |v|
      v.description = "#{college_name} resource room"
      v.department = college_name
      v.tenant = tenants[college_name]
    end
  end

  Venue.find_or_create_by!(name: "University Room") do |v|
    v.description = "University shared resource room accessible by all college students"
    v.department = "University"
    v.tenant = tenants["University"]
  end

  # Create admin account
  puts "Creating admin account..."
  User.find_or_create_by!(email: "admin@link.cuhk.edu.hk") do |u|
    u.password = "Password1!"
    u.password_confirmation = "Password1!"
    u.role = :admin
    u.tenant = tenants["University"]
  end

  # Create root staff account for each college
  puts "Creating root staff accounts..."
  root_staff_emails.each do |college_name, email|
    User.find_or_create_by!(email: email) do |u|
      u.password = "Password1!"
      u.password_confirmation = "Password1!"
      u.role = :staff
      u.is_root_account = true
      u.tenant = tenants[college_name]
    end
  end

  puts "Seed data created successfully."
  puts ""
  puts "=== Seeded Accounts ==="
  puts "Admin: admin@link.cuhk.edu.hk / Password1!"
  puts ""
  puts "Root Staff Accounts (one per college):"
  root_staff_emails.each do |college_name, email|
    puts "  #{college_name}: #{email} / Password1!"
  end
else
  puts "Skipping dummy data generation in production environment."
end
