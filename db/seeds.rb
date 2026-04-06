# Seed data for CUHK Booking System

# Only create dummy users in development/test environments
departments = ["University", "Chung Chi College", "New Asia College", "United College", "Shaw College", "S.H. Ho College", "CW Chu College",
   "Wu Yee Sun College", "Lee Woo Sing College"]

unless Rails.env.production?
  # Create venues
  puts "Creating venues..."
  venues = [
    { name: "Room G04 Pommerenke Student Centre", description: "Pommerenke Student Centre (Music Room)", department: "University" },
    { name: "Room G05 Pommerenke Student Centre", description: "Pommerenke Student Centre (Piano-practice Rooms)", department: "University" },
    { name: "Room G06 Pommerenke Student Centre", description: "Pommerenke Student Centre (Piano-practice Rooms)", department: "University" },
    { name: "Room G07 Pommerenke Student Centre", description: "Pommerenke Student Centre (Piano-practice Rooms)", department: "University" },
    { name: "Snooker Room at Pommerenke Student Centre", description: "Pommerenke Student Centre (Snooker Room)", department: "University" },
    { name: "Band Room at Pommerenke Student Centre", description: "Pommerenke Student Centre (Band Room)", department: "University" },
    { name: "CCSDC KSC LG2 Meeting Room", description: "CCSDC KSC LG2 Meeting Room", department: "Chung Chi College" },
    { name: "CCSDC KSC LG4 Activity Rooms", description: "CCSDC KSC LG4 Activity Rooms", department: "Chung Chi College" },
    { name: "CCSDC KSC LG5 Band Room", description: "CCSDC KSC LG5 Band Room", department: "Chung Chi College" },
    { name: "CCSDC KSC LG5 Music Rooms", description: "CCSDC KSC LG5 Music Rooms", department: "Chung Chi College" },
    { name: "Mrs. David Lam Hall", description: "Mrs. David Lam Hall", department: "New Asia College" },
    { name: "Mrs. David Lam Hall (Storage Area)", description: "Mrs. David Lam Hall (Storage Area)", department: "New Asia College" },
    { name: "Handicraft Room", description: "Handicraft Room", department: "New Asia College" },
    { name: "Yali Lounge", description: "Yali Lounge", department: "New Asia College" },
    { name: "New Asia Amphitheatre", description: "New Asia Amphitheatre", department: "New Asia College" },
    { name: "Foyer next to the Staff/Student Centre - Leung Hung Kee Building", description: "Foyer next to the Staff/Student Centre - Leung Hung Kee Building", department: "New Asia College" },
    { name: "Hui Kwok Hau Hall", description: "Hui Kwok Hau Hall", department: "New Asia College" },
    { name: "New Asia BBQ Pit No.1", description: "next to Staff Student Centre — Leung Hung Kee Building", department: "New Asia College" },
    { name: "New Asia BBQ Pit No.2", description: "next to Grace Tien Hall and Daisy Li Hall", department: "New Asia College" },
    { name: "Lawn in front of Adam Schall", description: "Lawn in front of Adam Schall", department: "United College" },
    { name: "Open area in front of Cheung Chuk Shan Amenities Building", description: "Open area in front of Cheung Chuk Shan Amenities Building", department: "United College" },
    { name: "Atrium outside C1, T C Cheng Building (UCC)", description: "Atrium outside C1, T C Cheng Building (UCC)", department: "United College" },
    { name: "Open Area in front of Tsang Shiu Tim Building (UCA)", description: "Open Area in front of Tsang Shiu Tim Building (UCA)", department: "United College" },
    { name: "Student Common Room (Rm 203), 2/F Cheung Chuk Shan Amenities Building", description: "Student Common Room (Rm 203), 2/F Cheung Chuk Shan Amenities Building", department: "United College" },
    { name: "Mirror Room (Rm 208 & 209), 2/F Cheung Chuk Shan Amenities Building", description: "Mirror Room (Rm 208 & 209), 2/F Cheung Chuk Shan Amenities Building", department: "United College" },
    { name: "Shaw College Lecture Theatre", description: "G/F & 1/F, Lecture Theatre, Shaw College", department: "Shaw College" },
    { name: "Yueh Chiao Art Gallery", description: "1/F, Lecture Theatre, Shaw College", department: "Shaw College" },
    { name: "Fu Zung Centre", description: "G/F, Kuo Mou Hall, Shaw College", department: "Shaw College" },
    { name: "Multi-Purpose Activity Rooms LG201", description: "LG201, Wen Lan Tang, Shaw College", department: "Shaw College" },
    { name: "Multi-Purpose Activity Rooms LG502", description: "LG502, Wen Lan Tang, Shaw College", department: "Shaw College" },
    { name: "Multi-Purpose Activity Rooms LG601", description: "LG601, Wen Lan Tang, Shaw College", department: "Shaw College" },
    { name: "Music Rooms LG307", description: "LG307, Wen Lan Tang, Shaw College", department: "Shaw College" },
    { name: "Music Rooms LG504", description: "LG504, Wen Lan Tang, Shaw College", department: "Shaw College" },
    { name: "Band Room LG503", description: "LG503, Wen Lan Tang, Shaw College", department: "Shaw College" },
    { name: "Indoor Multi-purpose Sports Hall", description: "LG2, Kuo Mou Hall, Shaw College", department: "Shaw College" },
    { name: "Dancing Room", description: "LG3, Kuo Mou Hall, Shaw College", department: "Shaw College" },
    { name: "Table-tennis Room", description: "LG3, Kuo Mou Hall, Shaw College", department: "Shaw College" },
    { name: "Tennis Courts", description: "Tennis Courts", department: "Shaw College" },
    { name: "Chan Chun Ha Hall Seminar Room 1", description: "G/F, Chan Chun Ha Hall Seminar Room 1 (60 seats)", department: "S.H. Ho College" },
    { name: "Chan Chun Ha Hall Seminar Room 2", description: "G/F, Chan Chun Ha Hall Seminar Room 2 (100 seats)", department: "S.H. Ho College" },
    { name: "Chan Chun Ha Hall Theatre", description: "1/F, Chan Chun Ha Hall Theatre (60 seats)", department: "S.H. Ho College" },
    { name: "Chan Chun Ha Hall Common Rooms", description: "3/F, Chan Chun Ha Hall Common Rooms", department: "S.H. Ho College" },
    { name: "Chan Chun Ha Hall Activity Room", description: "3/F, Chan Chun Ha Hall Activity Room", department: "S.H. Ho College" },
    { name: "Ho Sin Hang Hall", description: "Ho Sin Hang Hall", department: "S.H. Ho College" },
    { name: "CW Chu College Hostel Activity Room 1 (Room 213)", description: "CW Chu College Hostel Activity Room 1 (Room 213)", department: "CW Chu College" },
    { name: "CW Chu College Hostel Music Room", description: "CW Chu College Hostel Music Room", department: "CW Chu College" },
    { name: "Wu Yee Sun College Activity Room", description: "Wu Yee Sun College Activity Room(W116)", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College Music Room", description: "Wu Yee Sun College Music Room", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College Creativity Laboratory", description: "Wu Yee Sun College Creativity Laboratory", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College Seminar Room W112", description: "Wu Yee Sun College Seminar Room(W112)", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College Seminar Room W113", description: "Wu Yee Sun College Seminar Room(W113)", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College Seminar Room W114", description: "Wu Yee Sun College Seminar Room(W114)", department: "Wu Yee Sun College" },
    { name: "LG2 Dining Hall", description: "LG2 Dining Hall", department: "Lee Woo Sing College" },
    { name: "LG1 Mini Theatre", description: "LG1 Mini Theatre", department: "Lee Woo Sing College" },
    { name: "LG1 Anthony Wu Seminar Room", description: "LG1 Anthony Wu Seminar Room", department: "Lee Woo Sing College" },
    { name: "LG1 Agnes Lau Seminar Room", description: "LG1 Agnes Lau Seminar Room", department: "Lee Woo Sing College" },
    { name: "LG3 Multi-purpose Hall", description: "LG3 Multi-purpose Hall", department: "Lee Woo Sing College" },
    { name: "Cookery Demonstration Room", description: "Room 204, Dorothy and Ti-Hua KOO Building", department: "Lee Woo Sing College" },
    { name: "Music Room 1 (Piano Room)", description: "Room G02, G/F, Dorothy and Ti-Hua KOO Building", department: "Lee Woo Sing College" },
    { name: "Music Room 2 (Band Room)", description: "Room G03, G/F, Dorothy and Ti-Hua KOO Building", department: "Lee Woo Sing College" },
    { name: "Music Centre", description: "Room G04, G/F, Dorothy and Ti-Hua KOO Building", department: "Lee Woo Sing College" },
    { name: "Multimedia Studio", description: "Room LG103A, LG1/F, North Block", department: "Lee Woo Sing College" }
  ]

  # Build a readable department list from venues, then create one tenant per department.
  
  department_tenants = {}

  departments.each do |department_name|
    department_tenants[department_name] = Tenant.find_or_create_by!(slug: department_name.parameterize) do |t|
      t.name = department_name
      t.description = "#{department_name} facilities"
    end
  end

  university_tenant = department_tenants.fetch("University")

  puts "Creating equipments..."
  equipments = []

  # Create default admin user
  User.find_or_create_by!(email: "admin@cuhk.edu.hk") do |u|
    u.password = "Password1!"
    u.role = :admin
  end

  # Create default staff user
  User.find_or_create_by!(email: "staff@cuhk.edu.hk") do |u|
    u.password = "Password1!"
    u.role = :staff
    u.tenant = university_tenant
  end

  # Create default member user
  member = User.find_or_create_by!(email: "member@cuhk.edu.hk") do |u|
    u.password = "Password1!"
    u.role = :society_member
    u.tenant = university_tenant
  end

  # Create additional cross-tenant test users.
  test_users = [
    { email: "staff.shaw@cuhk.edu.hk", role: :staff, tenant: "Shaw College" },
    { email: "staff.newasia@cuhk.edu.hk", role: :staff, tenant: "New Asia College" },
    { email: "staff.wys@cuhk.edu.hk", role: :staff, tenant: "Wu Yee Sun College" },
    { email: "member.shaw@cuhk.edu.hk", role: :society_member, tenant: "Shaw College" },
    { email: "member.newasia@cuhk.edu.hk", role: :society_member, tenant: "New Asia College" },
    { email: "member.wys@cuhk.edu.hk", role: :society_member, tenant: "Wu Yee Sun College" }
  ]

  test_users.each do |attrs|
    User.find_or_create_by!(email: attrs[:email]) do |u|
      u.password = "Password1!"
      u.role = attrs[:role]
      u.tenant = department_tenants.fetch(attrs[:tenant])
    end
  end

  created_venues = venues.map do |venue_attrs|
    Venue.find_or_create_by!(name: venue_attrs[:name]) do |v|
      v.description = venue_attrs[:description]
      v.department = venue_attrs[:department]
      v.tenant = department_tenants.fetch(venue_attrs[:department])
    end
  end

  created_equipments = equipments.map do |equipment_attrs|
    Equipment.find_or_create_by!(name: equipment_attrs[:name]) do |e|
      e.quantity = equipment_attrs[:quantity]
      e.tenant = department_tenants.fetch(equipment_attrs[:tenant])
    end
  end
  # Create bookings
  # puts "Creating bookings..."
  # 5.times do |i|
  #   VenueBooking.find_or_create_by!(
  #     venue: created_venues[i],
  #     user: member,
  #     start_time: Time.current + (i + 1).days,
  #     end_time: Time.current + (i + 1).days + 2.hours
  #   )
  # end

  puts "Seed data created successfully."
  puts "  Admin:  admin@cuhk.edu.hk  / Password1!"
  puts "  Staff:  staff@cuhk.edu.hk  / Password1!"
  puts "  Member: member@cuhk.edu.hk / Password1!"
  puts "  Extra staff users:"
  puts "    staff.shaw@cuhk.edu.hk, staff.newasia@cuhk.edu.hk, staff.wys@cuhk.edu.hk"
  puts "  Extra member users:"
  puts "    member.shaw@cuhk.edu.hk, member.newasia@cuhk.edu.hk, member.wys@cuhk.edu.hk"
else
  puts "Skipping dummy data generation in production environment."
end
