Given('there is a tenant {string}') do |name|
  create(:tenant, name: name, slug: name.downcase.gsub(' ', '-'))
end

Given('there is a society {string}') do |name|
  create(:society, name: name)
end

Given('there is a user {string} with role {string}') do |email, role|
  tenant = Tenant.first || create(:tenant, name: 'University', slug: 'university')
  create(:user, email: email, password: 'Password1!', password_confirmation: 'Password1!', role: role.to_sym, tenant: tenant)
end

Given('I am logged in as {string}') do |email|
  user = User.find_by!(email: email)
  user.update!(active_session_token: nil)
  password = ["password", "password1", "Password1!"].find { |value| user.authenticate(value) }
  raise "No valid password found for #{email}" unless password

  visit login_path
  fill_in 'Email', with: email.to_s.split("@", 2).first
  fill_in 'Password', with: password
  click_button 'Sign In'
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

  # In non-JS runs, selecting start time does not dynamically repopulate end-time options.
  # Revisit the new booking page with start_slot so server-side filtering can populate end slots.
  next unless dropdown.in?(['booking_start_slot', 'Start time'])
  next if Capybara.current_driver == Capybara.javascript_driver
  next unless page.current_path == new_booking_path

  booking_date = find("input[name='booking[booking_date]']", visible: :all).value.presence ||
                 find_field('booking_date').value.presence
  venue_id = find("input[name='booking[venue_id]']", visible: :all).value.presence ||
             find("input[name='venue_id']", visible: :all).value.presence

  params = {
    booking_date: booking_date,
    venue_id: venue_id,
    booking: { start_slot: option }
  }.compact

  visit "#{new_booking_path}?#{params.to_query}"
end

When('I fill in {string} with a date {int} days in the future') do |field, days|
  future_date = (Date.current + days.days).strftime('%Y-%m-%d')
  fill_in field, with: future_date

  # The booking form submits booking[booking_date] from a hidden field.
  # Keep both fields synchronized in non-JS test runs.
  hidden_booking_date = find("input[name='booking[booking_date]']", visible: :all)
  hidden_booking_date.set(future_date)
end

Given('there is a booking for {string} by {string} from today at {string} to today at {string}') do |venue_name, user_email, start_time, end_time|
  venue = Venue.find_by(name: venue_name)
  user = User.find_by(email: user_email)
  # Create booking 5 days in the future to meet advance booking constraint
  booking_date = 5.days.from_now
  start_datetime = Time.zone.parse("#{booking_date.strftime('%Y-%m-%d')} #{start_time}:00")
  end_datetime = Time.zone.parse("#{booking_date.strftime('%Y-%m-%d')} #{end_time}:00")
  create(:booking, venue: venue, user: user, start_time: start_datetime, end_time: end_datetime)
end
