# Seed data for CUHK Booking System

# Only create dummy users in development/test environments
unless Rails.env.production?
  # Create default tenants
  cs_dept = Tenant.find_or_create_by!(slug: "cs-dept") do |t|
    t.name = "Computer Science Department"
    t.description = "Department of Computer Science and Engineering"
  end

  # Create University tenant for university-wide venues
  university_tenant = Tenant.find_or_create_by!(slug: "university") do |t|
    t.name = "University"
    t.description = "University-wide facilities"
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
    { name: "Room G04 Pommerenke Student Centre", description: "Pommerenke Student Centre (Music Room)", department: "University", tenant: university_tenant },
    { name: "Room G05 Pommerenke Student Centre", description: "Pommerenke Student Centre (Piano-practice Rooms)", department: "University", tenant: university_tenant },
    { name: "Room G06 Pommerenke Student Centre", description: "Pommerenke Student Centre (Piano-practice Rooms)", department: "University", tenant: university_tenant },
    { name: "Room G07 Pommerenke Student Centre", description: "Pommerenke Student Centre (Piano-practice Rooms)", department: "University", tenant: university_tenant },
    { name: "Snooker Room at Pommerenke Student Centre", description: "Pommerenke Student Centre (Snooker Room)", department: "University", tenant: university_tenant },
    { name: "Band Room at Pommerenke Student Centre", description: "Pommerenke Student Centre (Band Room)", department: "University", tenant: university_tenant }
  ]

  created_venues = venues.map do |venue_attrs|
    Venue.find_or_create_by!(name: venue_attrs[:name]) do |v|
      v.description = venue_attrs[:description]
      v.department = venue_attrs[:department]
      v.tenant = venue_attrs[:tenant]
    end
  end

  # Create bookings
  puts "Creating bookings..."
  5.times do |i|
    VenueBooking.find_or_create_by!(
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
