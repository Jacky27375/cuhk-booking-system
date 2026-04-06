# Seed data for CUHK Booking System

# Only create dummy users in development/test environments
departments = ["University", "Chung Chi College", "New Asia College", "United College", "Shaw College", "S.H. Ho College", "CW Chu College",
  "Wu Yee Sun College", "Lee Woo Sing College", "Morningside College"]

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

  additional_venues = [
    { name: "University Tennis Courts", description: "PEU central sports facilities", department: "University" },
    { name: "University Squash Court", description: "PEU central sports facilities", department: "University" },
    { name: "CU Fitness Room", description: "PEU central sports facilities", department: "University" },
    { name: "HCF Running Track", description: "PEU central sports facilities", department: "University" },
    { name: "University Sports Centre / Yeung Ming Biu Indoor Sports Centre", description: "PEU central sports facilities", department: "University" },
    { name: "Postgraduate Halls Tennis Court", description: "PEU central sports facilities", department: "University" },
    { name: "University Library Group Study Rooms", description: "1/F, 4-8 seats", department: "University" },
    { name: "University Library Bubble Group Study Rooms", description: "LG/F", department: "University" },
    { name: "University Library LG Creative Media Studio", description: "8 seats", department: "University" },
    { name: "University Library Study Pods", description: "2 seats", department: "University" },
    { name: "Lingnan Gymnasium", description: "Basketball and badminton", department: "Chung Chi College" },
    { name: "Pan Hua Dong Barbecue Area", description: "Outdoor barbecue area", department: "Chung Chi College" },
    { name: "Chung Chi Tang", description: "Large gathering venue", department: "Chung Chi College" },
    { name: "CCT 1/F South", description: "Event venue with AV support", department: "Chung Chi College" },
    { name: "CCT Lobby", description: "Event venue with AV support", department: "Chung Chi College" },
    { name: "CCT VIP Room", description: "Event venue with AV support", department: "Chung Chi College" },
    { name: "Elisabeth Luce Moore Library Group Discussion Rooms", description: "Group discussion rooms", department: "Chung Chi College" },
    { name: "Chung Chi College Library Group Study Rooms", description: "4-6 seats", department: "Chung Chi College" },
    { name: "Chung Chi College Library Listening Rooms", description: "Library listening rooms", department: "Chung Chi College" },
    { name: "Chung Chi College Library Music Room 1", description: "Library music room", department: "Chung Chi College" },
    { name: "Chung Chi College Library Music Room 2", description: "Library music room", department: "Chung Chi College" },
    { name: "Charles Leung Gymnasium", description: "College gymnasium", department: "New Asia College" },
    { name: "Ying-wai Fitness Room", description: "College fitness room", department: "New Asia College" },
    { name: "New Asia Dancing and Table Tennis Room", description: "Dancing and table tennis", department: "New Asia College" },
    { name: "New Asia College Library Group Study Room 1", description: "Library study room", department: "New Asia College" },
    { name: "New Asia College Library Group Study Room 2", description: "Library study room", department: "New Asia College" },
    { name: "New Asia College Library Group Study Room 3", description: "Library study room", department: "New Asia College" },
    { name: "United College Indoor Gymnasium", description: "Indoor sports hall", department: "United College" },
    { name: "United College Table-tennis Room", description: "College sports room", department: "United College" },
    { name: "United College Dance Room", description: "College activity room", department: "United College" },
    { name: "United College Barbecue Area", description: "Outdoor barbecue area", department: "United College" },
    { name: "United College Mini Projection Room", description: "Projection room", department: "United College" },
    { name: "United College Wu Chung Library Group Study Rooms", description: "Library study rooms 1-5", department: "United College" },
    { name: "Shaw Assembly Hall and Backstage", description: "Large venue", department: "Shaw College" },
    { name: "Shaw College Barbecue Area", description: "Outdoor barbecue area", department: "Shaw College" },
    { name: "Shaw G/F Foyer", description: "Exhibition and event space", department: "Shaw College" },
    { name: "Fook Yin Centre", description: "Medium event venue", department: "Shaw College" },
    { name: "Fong Yin Fun Art Heritage Gallery", description: "Exhibition venue", department: "Shaw College" },
    { name: "LG203 Classroom", description: "Classroom", department: "Shaw College" },
    { name: "LG204 Classroom", description: "Classroom", department: "Shaw College" },
    { name: "LG202 Meeting Room", description: "Meeting room", department: "Shaw College" },
    { name: "Shaw Terrace", description: "Outdoor venue", department: "Shaw College" },
    { name: "Podium outside Wen Lan Tang", description: "Outdoor venue", department: "Shaw College" },
    { name: "Shaw Road", description: "Outdoor venue", department: "Shaw College" },
    { name: "Kuo Mou Hall Covered Podium", description: "Outdoor covered venue", department: "Shaw College" },
    { name: "Student Hostel II Podium", description: "Outdoor venue", department: "Shaw College" },
    { name: "Area outside Student Hostel II Carpark", description: "Outdoor venue", department: "Shaw College" },
    { name: "S.H. Ho Mini Theatre", description: "Mini theatre", department: "S.H. Ho College" },
    { name: "S.H. Ho Fitness Room", description: "College fitness room", department: "S.H. Ho College" },
    { name: "S.H. Ho Multi-purpose Activity Rooms", description: "Activity rooms", department: "S.H. Ho College" },
    { name: "S.H. Ho Music Rooms", description: "Music rooms", department: "S.H. Ho College" },
    { name: "CW Chu Multi-purpose Activity Rooms", description: "Activity rooms", department: "CW Chu College" },
    { name: "CW Chu Fitness Room", description: "College fitness room", department: "CW Chu College" },
    { name: "CW Chu Practice Rooms", description: "Practice rooms", department: "CW Chu College" },
    { name: "Morningside Multi-purpose Rooms", description: "College multipurpose rooms", department: "Morningside College" },
    { name: "Morningside Fitness Room", description: "College fitness room", department: "Morningside College" },
    { name: "Morningside Music Rooms", description: "College music rooms", department: "Morningside College" },
    { name: "Wu Yee Sun The Lounge", description: "College lounge", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun Sports Hall", description: "College sports hall", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun Fitness Room", description: "College fitness room", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun Barbecue Area", description: "Outdoor barbecue area", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun Multi-purpose Sports Room", description: "Sports room", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College Gallery", description: "Activity and exhibition space", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun Sky Garden", description: "Outdoor venue", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College Theatre", description: "College theatre", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun Terrace of Dreams", description: "Outdoor venue", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun Central Courtyard", description: "Outdoor venue", department: "Wu Yee Sun College" },
    { name: "Wu Yee Sun Student Canteen", description: "Student canteen space", department: "Wu Yee Sun College" },
    { name: "Lee Woo Sing Indoor Sports Hall", description: "Indoor sports hall", department: "Lee Woo Sing College" },
    { name: "Lee Woo Sing Medium Theatre", description: "Medium theatre", department: "Lee Woo Sing College" },
    { name: "Lee Woo Sing Roof Garden / Barbecue Area", description: "Outdoor barbecue venue", department: "Lee Woo Sing College" },
    { name: "Lee Woo Sing Main Hall", description: "Main hall", department: "Lee Woo Sing College" },
    { name: "Lee Woo Sing Hu Dingxu Lecture Room", description: "Lecture room", department: "Lee Woo Sing College" },
    { name: "Lee Woo Sing Liu Qiu Haiyan Lecture Room", description: "Lecture room", department: "Lee Woo Sing College" },
    { name: "Lee Woo Sing SG01 Mixed Meeting Room", description: "Meeting room", department: "Lee Woo Sing College" },
    { name: "Lee Woo Sing SR5 Interactive Classroom", description: "Interactive classroom", department: "Lee Woo Sing College" },
    { name: "Lee Woo Sing Small Theatre", description: "Small theatre", department: "Lee Woo Sing College" }
  ]

  venues.concat(additional_venues)

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
  college_name_prefix_map = {
    "Chung Chi" => "Chung Chi College",
    "New Asia" => "New Asia College",
    "United" => "United College",
    "Shaw" => "Shaw College",
    "Wu Yee Sun" => "Wu Yee Sun College",
    "Lee Woo Sing" => "Lee Woo Sing College"
  }

  # Normalize older seed names so rerunning seeds won't create duplicates.
  college_name_prefix_map.each do |old_prefix, new_prefix|
    Equipment.where("name LIKE ?", "#{old_prefix} - %").find_each do |record|
      record.update!(name: record.name.sub("#{old_prefix} - ", "#{new_prefix} - "))
    end
  end

  equipments = [
    { name: "University - Sports Equipment Set", quantity: 30, tenant: "University" },
    { name: "University - Locker Keys", quantity: 120, tenant: "University" },
    { name: "Chung Chi College - Barbecue Grill Nets and Forks", quantity: 40, tenant: "Chung Chi College" },
    { name: "Chung Chi College - Wireless Microphone", quantity: 12, tenant: "Chung Chi College" },
    { name: "Chung Chi College - Portable Amplifier", quantity: 8, tenant: "Chung Chi College" },
    { name: "Chung Chi College - Stage and HDMI Cables", quantity: 20, tenant: "Chung Chi College" },
    { name: "New Asia College - Event Sound System", quantity: 6, tenant: "New Asia College" },
    { name: "New Asia College - Barbecue Utensils", quantity: 30, tenant: "New Asia College" },
    { name: "New Asia College - Display Boards", quantity: 25, tenant: "New Asia College" },
    { name: "New Asia College - Sports Equipment", quantity: 30, tenant: "New Asia College" },
    { name: "United College - Portable Amplifier TOA-620C", quantity: 1, tenant: "United College" },
    { name: "United College - Portable Amplifier Yuesheng", quantity: 1, tenant: "United College" },
    { name: "United College - Portable Amplifier Aoumeisheng 006-A/B", quantity: 2, tenant: "United College" },
    { name: "United College - Portable Amplifier NRS-DS2010UV", quantity: 1, tenant: "United College" },
    { name: "United College - Wired Microphone", quantity: 5, tenant: "United College" },
    { name: "United College - Microphone Stands", quantity: 6, tenant: "United College" },
    { name: "United College - Projector Epson EB-X18", quantity: 1, tenant: "United College" },
    { name: "United College - Projector Screen 6x6", quantity: 1, tenant: "United College" },
    { name: "United College - Long Tables", quantity: 20, tenant: "United College" },
    { name: "United College - Chairs", quantity: 28, tenant: "United College" },
    { name: "United College - Walkie Talkie", quantity: 8, tenant: "United College" },
    { name: "United College - Water-Proof Extension Leads", quantity: 10, tenant: "United College" },
    { name: "United College - Stage Platform Set", quantity: 1, tenant: "United College" },
    { name: "United College - Wireless Microphone with Receiver", quantity: 2, tenant: "United College" },
    { name: "United College - Mixer ALLEN and HEATH ZED 10FX", quantity: 1, tenant: "United College" },
    { name: "United College - Speaker Set with Stands", quantity: 1, tenant: "United College" },
    { name: "Shaw College - Barbecue Forks", quantity: 30, tenant: "Shaw College" },
    { name: "Shaw College - Portable Amplifiers", quantity: 8, tenant: "Shaw College" },
    { name: "Shaw College - Sports Equipment", quantity: 25, tenant: "Shaw College" },
    { name: "Wu Yee Sun College - 3D Printer", quantity: 3, tenant: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College - Laser Cutter", quantity: 2, tenant: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College - Recording Equipment", quantity: 4, tenant: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College - Drum Kit", quantity: 1, tenant: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College - Electronic Piano", quantity: 2, tenant: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College - Acoustic or Electric Guitar", quantity: 4, tenant: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College - Bass Guitar", quantity: 2, tenant: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College - Cajon", quantity: 2, tenant: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College - Amplifier and Mixer", quantity: 2, tenant: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College - Outdoor Amplifier", quantity: 1, tenant: "Wu Yee Sun College" },
    { name: "Wu Yee Sun College - Microphone with Cables and Stands", quantity: 8, tenant: "Wu Yee Sun College" },
    { name: "Lee Woo Sing College - Cooking Room Facilities", quantity: 10, tenant: "Lee Woo Sing College" },
    { name: "Lee Woo Sing College - Barbecue Utensils", quantity: 20, tenant: "Lee Woo Sing College" },
    { name: "Lee Woo Sing College - Basic Sound System", quantity: 6, tenant: "Lee Woo Sing College" }
  ]

  # Create default admin user
  User.find_or_create_by!(email: "admin@link.cuhk.edu.hk") do |u|
    u.password = "Password1!"
    u.password_confirmation = "Password1!"
    u.role = :admin
  end

  # Create default staff user
  User.find_or_create_by!(email: "staff@link.cuhk.edu.hk") do |u|
    u.password = "Password1!"
    u.password_confirmation = "Password1!"
    u.role = :staff
    u.tenant = university_tenant
  end

  # Create default member user
  member = User.find_or_create_by!(email: "member@link.cuhk.edu.hk") do |u|
    u.password = "Password1!"
    u.password_confirmation = "Password1!"
    u.role = :society_member
    u.tenant = university_tenant
  end

  # Create additional cross-tenant test users.
  test_users = [
    { email: "staff.shaw@link.cuhk.edu.hk", role: :staff, tenant: "Shaw College" },
    { email: "staff.newasia@link.cuhk.edu.hk", role: :staff, tenant: "New Asia College" },
    { email: "staff.wys@link.cuhk.edu.hk", role: :staff, tenant: "Wu Yee Sun College" },
    { email: "member.shaw@link.cuhk.edu.hk", role: :society_member, tenant: "Shaw College" },
    { email: "member.newasia@link.cuhk.edu.hk", role: :society_member, tenant: "New Asia College" },
    { email: "member.wys@link.cuhk.edu.hk", role: :society_member, tenant: "Wu Yee Sun College" }
  ]

  test_users.each do |attrs|
    User.find_or_create_by!(email: attrs[:email]) do |u|
      u.password = "Password1!"
      u.password_confirmation = "Password1!"
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
  puts "  Admin:  admin@link.cuhk.edu.hk  / Password1!"
  puts "  Staff:  staff@link.cuhk.edu.hk  / Password1!"
  puts "  Member: member@link.cuhk.edu.hk / Password1!"
  puts "  Extra staff users:"
  puts "    staff.shaw@link.cuhk.edu.hk, staff.newasia@link.cuhk.edu.hk, staff.wys@link.cuhk.edu.hk"
  puts "  Extra member users:"
  puts "    member.shaw@link.cuhk.edu.hk, member.newasia@link.cuhk.edu.hk, member.wys@link.cuhk.edu.hk"
else
  puts "Skipping dummy data generation in production environment."
end
