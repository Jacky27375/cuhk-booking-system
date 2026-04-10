Given('the following tenants exist:') do |table|
  table.hashes.each do |row|
    Tenant.find_or_create_by!(slug: row['name'].parameterize) do |tenant|
      tenant.name = row['name']
    end
  end
end

Given('I am logged in as a {string} of {string}') do |role, tenant_name|
  tenant = Tenant.find_by(name: tenant_name)
  role_enum = role
  @current_user = User.create!(
    email: "#{role}.#{tenant.slug}@link.cuhk.edu.hk",
    password: 'Password1!',
    password_confirmation: 'Password1!',
    role: role_enum,
    tenant: tenant
  )

  visit '/login'
  fill_in 'Email', with: @current_user.email.to_s.split("@", 2).first
  fill_in 'Password', with: 'Password1!'
  click_button 'Sign In'
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
  user = User.create!(email: "booker.#{Time.now.to_i}@link.cuhk.edu.hk", password: 'Password1!', password_confirmation: 'Password1!', role: 'student', tenant: venue.tenant || Tenant.first)
  booking = Booking.create!(venue: venue, user: user, start_time: 1.day.from_now.change(hour: 10, min: 0), end_time: 1.day.from_now.change(hour: 12, min: 0), status: 'pending')

  visit '/approval_dashboard'
  expect(page).to have_content(venue_name)
end

Then('I cannot access bookings for {string}') do |venue_name|
  venue = Venue.find_by(name: venue_name)
  if venue
    user = User.create!(email: "booker.#{Time.now.to_i}.#{rand(1000)}@link.cuhk.edu.hk", password: 'Password1!', password_confirmation: 'Password1!', role: 'student', tenant: venue.tenant || Tenant.first)
    booking = Booking.create!(venue: venue, user: user, start_time: 1.day.from_now.change(hour: 10, min: 0), end_time: 1.day.from_now.change(hour: 12, min: 0), status: 'pending')
  end
  visit '/approval_dashboard'
  expect(page).not_to have_content(venue_name)
end

Given('the following equipments exist:') do |table|
  table.hashes.each do |row|
    tenant = Tenant.find_by!(name: row['tenant'])
    Equipment.find_or_create_by!(name: row['name'], tenant: tenant) do |equipment|
      equipment.quantity = row['quantity'].to_i
    end
  end
end

Given('the following pending bookings exist:') do |table|
  table.hashes.each do |row|
    venue = Venue.find_by!(name: row['venue'])
    user = User.find_or_create_by!(email: row['user_email']) do |u|
      u.password = 'Password1!'
      u.password_confirmation = 'Password1!'
      u.role = :student
      u.tenant = venue.tenant
    end

    Booking.create!(
      venue: venue,
      user: user,
      start_time: 1.day.from_now.change(hour: 10, min: 0),
      end_time: 1.day.from_now.change(hour: 12, min: 0),
      status: :pending
    )
  end
end

When('I visit the equipments page') do
  visit '/equipments'
end
