Given('there is a tenant {string}') do |name|
  create(:tenant, name: name, slug: name.downcase.gsub(' ', '-'))
end

Given('there is a society {string}') do |name|
  create(:society, name: name)
end

Given('there is a user {string} with role {string}') do |email, role|
  tenant = Tenant.first || create(:tenant, name: 'University', slug: 'university')
  create(:user, email: email, password: 'password', role: role.to_sym, tenant: tenant)
end

Given('I am logged in as {string}') do |email|
  user = User.find_by!(email: email)
  password = ["password", "password1", "Password1!"].find { |value| user.authenticate(value) }
  raise "No valid password found for #{email}" unless password

  visit login_path
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Log in'
end

When('I visit the venues page') do
  visit venues_path
end

Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end

Given('there is a venue {string}') do |name|
  tenant = Tenant.find_by(slug: 'university') || create(:tenant, name: 'University', slug: 'university')
  create(:venue, name: name, department: 'University', tenant: tenant)
end

When('I visit the bookings page') do
  visit bookings_path
end

Given('there is a booking for {string} by {string} from {string} to {string}') do |venue_name, user_email, start_time, end_time|
  venue = Venue.find_by(name: venue_name)
  user = User.find_by(email: user_email)
  create(:booking, venue: venue, user: user, start_time: start_time, end_time: end_time)
end

When('I select {string} from {string}') do |option, dropdown|
  select option, from: dropdown
end
