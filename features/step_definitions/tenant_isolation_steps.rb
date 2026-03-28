Given('the following tenants exist:') do |table|
  table.hashes.each do |row|
    Tenant.create!(name: row['name'], slug: row['name'].parameterize)
  end
end

Given('I am logged in as a {string} of {string}') do |role, tenant_name|
  tenant = Tenant.find_by(name: tenant_name)
  role_enum = role == 'student' ? 'society_member' : 'staff'
  @current_user = User.create!(
    email: "#{role}@#{tenant.slug}.edu", 
    password: 'password', 
    role: role_enum, 
    tenant: tenant
  )
  
  visit '/login'
  fill_in 'Email', with: @current_user.email
  fill_in 'Password', with: 'password'
  click_button 'Log in'
end

When('I view the bookable venues list') do
  visit '/venues'
end

When('I view the approval dashboard') do
  visit '/approval_dashboard'
end

Then('I can approve bookings for {string}') do |venue_name|
  venue = Venue.find_by(name: venue_name)
  # Create a pending booking for this venue so it shows up
  user = User.create!(email: "test_booker_#{Time.now.to_i}@test.com", password: 'password', role: 'society_member', tenant: venue.tenant || Tenant.first)
  booking = Booking.create!(venue: venue, user: user, start_time: 1.day.from_now, end_time: 1.day.from_now + 2.hours, status: 'pending')
  
  visit '/approval_dashboard'
  expect(page).to have_content(venue_name)
end

Then('I cannot access bookings for {string}') do |venue_name|
  venue = Venue.find_by(name: venue_name)
  if venue
    user = User.create!(email: "test_booker_#{Time.now.to_i}_#{rand(1000)}@test.com", password: 'password', role: 'society_member', tenant: venue.tenant || Tenant.first)
    booking = Booking.create!(venue: venue, user: user, start_time: 1.day.from_now, end_time: 1.day.from_now + 2.hours, status: 'pending')
  end
  visit '/approval_dashboard'
  expect(page).not_to have_content(venue_name)
end