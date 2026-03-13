# Seed data for CUHK Booking System

# Only create dummy users in development/test environments
unless Rails.env.production?
  # Create default tenants
  cs_dept = Tenant.find_or_create_by!(slug: "cs-dept") do |t|
    t.name = "Computer Science Department"
    t.description = "Department of Computer Science and Engineering"
  end

  sc_college = Tenant.find_or_create_by!(slug: "shaw-college") do |t|
    t.name = "Shaw College"
    t.description = "Shaw College, CUHK"
  end

  # Create default society
  cs_society = Society.find_or_create_by!(name: "Computer Science Society") do |s|
    s.description = "CUHK Computer Science Student Society"
  end

  # Create default admin user
  User.find_or_create_by!(email: "admin@cuhk.edu.hk") do |u|
    u.password = "Password1!"
    u.role = :admin
  end

  # Create default staff user
  User.find_or_create_by!(email: "staff@cuhk.edu.hk") do |u|
    u.password = "Password1!"
    u.role = :staff
    u.tenant = cs_dept
  end

  # Create default society member
  User.find_or_create_by!(email: "member@cuhk.edu.hk") do |u|
    u.password = "Password1!"
    u.role = :society_member
    u.society = cs_society
  end

  puts "Seed data created successfully."
  puts "  Admin:  admin@cuhk.edu.hk  / Password1!"
  puts "  Staff:  staff@cuhk.edu.hk  / Password1!"
  puts "  Member: member@cuhk.edu.hk / Password1!"
else
  puts "Skipping dummy data generation in production environment."
end
