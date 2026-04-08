Given('the following users exist:') do |table|
  table.hashes.each do |hash|
    role_name = hash['role']
    role_name = 'society_member' if role_name == 'student'
    role = role_name.to_sym

    tenant = Tenant.find_by(name: "Science Faculty") || create(:tenant, name: "Science Faculty")

    user = User.find_or_initialize_by(email: hash['email'])
    user.password = hash['password']
    user.password_confirmation = hash['password']
    user.role = role
    user.tenant = tenant
    user.save!
  end
end

Given('I am on the login page') do
  visit login_path
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I press {string}') do |button|
  click_button button
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should see {string} only once') do |text|
  occurrences = page.text.scan(Regexp.new(Regexp.escape(text))).size
  expect(occurrences).to eq(1)
end

Given('I am logged in as {string} with password {string}') do |email, password|
  visit login_path
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Sign In'
end

When('I click {string}') do |link_or_button|
  click_on link_or_button
end

Then('I should be on the login page') do
  expect(current_path).to eq(login_path)
end

When('I try to visit the dashboard') do
  visit dashboard_path
end

When('I visit the admin panel') do
  visit admin_path
end

When('I visit my bookings page') do
  visit my_bookings_path
end

When('I try to edit the booking for {string} on {string}') do |venue_name, date|
  booking = Booking.joins(:venue)
                   .where(venues: { name: venue_name })
                   .where(start_time: Time.zone.parse(date).all_day)
                   .first!
  visit edit_booking_path(booking)
end

Then('the first row in table {string} should contain {string}') do |table_id, text|
  expect(page).to have_css("##{table_id} tbody tr:first-child", text: text)
end

Then('table {string} should have class {string}') do |table_id, class_name|
  expect(page).to have_css("table##{table_id}.#{class_name}")
end

Then('I should see link {string}') do |text|
  expect(page).to have_selector('a', text: text)
end

Then('I should not see link {string}') do |text|
  expect(page).not_to have_selector('a', text: text)
end
