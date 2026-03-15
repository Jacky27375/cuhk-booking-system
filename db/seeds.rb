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
  member = User.find_or_create_by!(email: "member@cuhk.edu.hk") do |u|
    u.password = "Password1!"
    u.role = :society_member
    u.society = cs_society
  end

  # Create venues
  puts "Creating venues..."
  venues = [
    { name: "Lecture Sol 1", description: "Large hall for 200 people" },
    { name: "Meeting Room A", description: "Small meeting room for 10 people" },
    { name: "Computer Lab 1", description: "Lab with 30 computers" },
    { name: "Conference Room B", description: "Medium conference room for 30 people" },
    { name: "Audit Hall", description: "Large auditorium for 500 people" }
  ]

  created_venues = venues.map do |venue_attrs|
    Venue.find_or_create_by!(name: venue_attrs[:name]) do |v|
      v.description = venue_attrs[:description]
    end
  end

  # Create bookings
  puts "Creating bookings..."
  5.times do |i|
    Booking.find_or_create_by!(
      venue: created_venues[i],
      user: member,
      start_time: Time.current + (i + 1).days,
      end_time: Time.current + (i + 1).days + 2.hours
    )
  end

  puts "Seed data created successfully."
  puts "  Admin:  admin@cuhk.edu.hk  / Password1!"
  puts "  Staff:  staff@cuhk.edu.hk  / Password1!"
  puts "  Member: member@cuhk.edu.hk / Password1!"
else
  puts "Skipping dummy data generation in production environment."
end
