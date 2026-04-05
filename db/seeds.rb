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
    { name: "Band Room at Pommerenke Student Centre", description: "Pommerenke Student Centre (Band Room)", department: "University", tenant: university_tenant },
    { name: "CCSDC KSC LG2 Meeting Room", description: "CCSDC KSC LG2 Meeting Room", department: "Chung Chi College", tenant: cc_college },
    { name: "CCSDC KSC LG4 Activity Rooms", description: "CCSDC KSC LG4 Activity Rooms", department: "Chung Chi College", tenant: cc_college },
    { name: "CCSDC KSC LG5 Band Room", description: "CCSDC KSC LG5 Band Room", department: "Chung Chi College", tenant: cc_college },
    { name: "CCSDC KSC LG5 Music Rooms", description: "CCSDC KSC LG5 Music Rooms", department: "Chung Chi College", tenant: cc_college },
    { name: "Mrs. David Lam Hall", description: "Mrs. David Lam Hall", department: "New Asia College", tenant: na_college },
    { name: "Mrs. David Lam Hall (Storage Area)", description: "Mrs. David Lam Hall (Storage Area)", department: "New Asia College", tenant: na_college },
    { name: "Handicraft Room", description: "Handicraft Room", department: "New Asia College", tenant: na_college },
    { name: "Yali Lounge", description: "Yali Lounge", department: "New Asia College", tenant: na_college },
    { name: "New Asia Amphitheatre", description: "New Asia Amphitheatre", department: "New Asia College", tenant: na_college },
    { name: "Foyer next to the Staff/Student Centre – Leung Hung Kee Building", description: "Foyer next to the Staff/Student Centre - Leung Hung Kee Building", department: "New Asia College", tenant: na_college },
    { name: "Hui Kwok Hau Hall", description: "Hui Kwok Hau Hall", department: "New Asia College", tenant: na_college },
    { name: "New Asia BBQ Pit No.1", description: "next to Staff Student Centre — Leung Hung Kee Building", department: "New Asia College", tenant: na_college },
    { name: "New Asia BBQ Pit No.2", description: "next to Grace Tien Hall and Daisy Li Hall", department: "New Asia College", tenant: na_college },
    { name: "Lawn in front of Adam Schall", description: "Lawn in front of Adam Schall", department: "United College", tenant: uc_college },
    { name: "Open area in front of Cheung Chuk Shan Amenities Building", description: "Open area in front of Cheung Chuk Shan Amenities Building", department: "United College", tenant: uc_college },
    { name: "Atrium outside C1, T C Cheng Building (UCC)", description: "Atrium outside C1, T C Cheng Building (UCC)", department: "United College", tenant: uc_college },
    { name: "Open Area in front of Tsang Shiu Tim Building (UCA)", description: "Open Area in front of Tsang Shiu Tim Building (UCA)", department: "United College", tenant: uc_college },
    { name: "Student Common Room (Rm 203), 2/F Cheung Chuk Shan Amenities Building", description: "Student Common Room (Rm 203), 2/F Cheung Chuk Shan Amenities Building", department: "United College", tenant: uc_college },
    { name: "Mirror Room (Rm 208 & 209), 2/F Cheung Chuk Shan Amenities Building", description: "Mirror Room (Rm 208 & 209), 2/F Cheung Chuk Shan Amenities Building", department: "United College", tenant: uc_college },
    { name: "Shaw College Lecture Theatre", description: "G/F & 1/F, Lecture Theatre, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Yueh Chiao Art Gallery", description: "1/F, Lecture Theatre, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Fu Zung Centre", description: "G/F, Kuo Mou Hall, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Multi-Purpose Activity Rooms LG201", description: "LG201, Wen Lan Tang, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Multi-Purpose Activity Rooms LG502", description: "LG502, Wen Lan Tang, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Multi-Purpose Activity Rooms LG601", description: "LG601, Wen Lan Tang, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Music Rooms LG307", description: "LG307, Wen Lan Tang, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Music Rooms LG504", description: "LG504, Wen Lan Tang, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Band Room LG503", description: "LG503, Wen Lan Tang, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Indoor Multi-purpose Sports Hall", description: "LG2, Kuo Mou Hall, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Dancing Room", description: "LG3, Kuo Mou Hall, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Table-tennis Room", description: "LG3, Kuo Mou Hall, Shaw College", department: "Shaw College", tenant: sc_college },
    { name: "Tennis Courts", description: "Tennis Courts", department: "Shaw College", tenant: sc_college },
    { name: "Chan Chun Ha Hall Seminar Room 1", description: "G/F, Chan Chun Ha Hall Seminar Room 1 (60 seats)", department: "S.H. Ho College", tenant: sh_college },
    { name: "Chan Chun Ha Hall Seminar Room 2", description: "G/F, Chan Chun Ha Hall Seminar Room 2 (100 seats)", department: "S.H. Ho College", tenant: sh_college },
    { name: "Chan Chun Ha Hall Theatre", description: "1/F, Chan Chun Ha Hall Theatre (60 seats)", department: "S.H. Ho College", tenant: sh_college },
    { name: "Chan Chun Ha Hall Common Rooms", description: "3/F, Chan Chun Ha Hall Common Rooms", department: "S.H. Ho College", tenant: sh_college },
    { name: "Chan Chun Ha Hall Activity Room", description: "3/F, Chan Chun Ha Hall Activity Room", department: "S.H. Ho College", tenant: sh_college },
    { name: "Ho Sin Hang Hall", description: "Ho Sin Hang Hall", department: "S.H. Ho College", tenant: sh_college },
    { name: "CW Chu College Hostel Activity Room 1 (Room 213)", description: "CW Chu College Hostel Activity Room 1 (Room 213)", department: "CW Chu College", tenant: cw_college },
    { name: "CW Chu College Hostel Music Room", description: "CW Chu College Hostel Music Room", department: "CW Chu College", tenant: cw_college },
    { name: "Wu Yee Sun College Activity Room", description: "Wu Yee Sun College Activity Room(W116)", department: "Wu Yee Sun College", tenant: wys_college },
    { name: "Wu Yee Sun College Music Room", description: "Wu Yee Sun College Music Room", department: "Wu Yee Sun College", tenant: wys_college },
    { name: "Wu Yee Sun College Creativity Laboratory", description: "Wu Yee Sun College Creativity Laboratory", department: "Wu Yee Sun College", tenant: wys_college },
    { name: "Wu Yee Sun College Seminar Room W112", description: "Wu Yee Sun College Seminar Room(W112)", department: "Wu Yee Sun College", tenant: wys_college },
    { name: "Wu Yee Sun College Seminar Room W113", description: "Wu Yee Sun College Seminar Room(W113)", department: "Wu Yee Sun College", tenant: wys_college },
    { name: "Wu Yee Sun College Seminar Room W114", description: "Wu Yee Sun College Seminar Room(W114)", department: "Wu Yee Sun College", tenant: wys_college },
    { name: "LG2 Dining Hall", description: "LG2 Dining Hall", department: "Lee Woo Sing College", tenant: lw_college },
    { name: "LG1 Mini Theatre", description: "LG1 Mini Theatre", department: "Lee Woo Sing College", tenant: lw_college },
    { name: "LG1 Anthony Wu Seminar Room", description: "LG1 Anthony Wu Seminar Room", department: "Lee Woo Sing College", tenant: lw_college },
    { name: "LG1 Agnes Lau Seminar Room", description: "LG1 Agnes Lau Seminar Room", department: "Lee Woo Sing College", tenant: lw_college },
    { name: "LG3 Multi-purpose Hall", description: "LG3 Multi-purpose Hall", department: "Lee Woo Sing College", tenant: lw_college },
    { name: "Cookery Demonstration Room", description: "Room 204, Dorothy and Ti-Hua KOO Building", department: "Lee Woo Sing College", tenant: lw_college },
    { name: "Music Room 1 (Piano Room)", description: "Room G02, G/F, Dorothy and Ti-Hua KOO Building", department: "Lee Woo Sing College", tenant: lw_college },
    { name: "Music Room 2 (Band Room)", description: "Room G03, G/F, Dorothy and Ti-Hua KOO Building", department: "Lee Woo Sing College", tenant: lw_college },
    { name: "Music Centre", description: "Room G04, G/F, Dorothy and Ti-Hua KOO Building", department: "Lee Woo Sing College", tenant: lw_college },
    { name: "Multimedia Studio", description: "Room LG103A, LG1/F, North Block", department: "Lee Woo Sing College", tenant: lw_college }
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
