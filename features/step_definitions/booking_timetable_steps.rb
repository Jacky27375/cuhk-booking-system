When('I open the booking page for {string} on {string}') do |venue_name, date|
  venue = Venue.find_by!(name: venue_name)
  visit new_booking_path(venue_id: venue.id, booking_date: date)
end

When('I open the booking page for {string} on a date {int} days in the future') do |venue_name, days|
  venue = Venue.find_by!(name: venue_name)
  date = (Date.current + days.days).strftime('%Y-%m-%d')
  visit new_booking_path(venue_id: venue.id, booking_date: date)
end

When('I open the edit booking page for my booking on {string}') do |date|
  booking = Booking.joins(:user).where(users: { email: 'member@link.cuhk.edu.hk' }).where(start_time: Time.zone.parse("#{date} 00:00:00")..Time.zone.parse("#{date} 23:59:59")).first!
  visit edit_booking_path(booking, booking_date: date)
end

When('I open the edit booking page for my booking on a date {int} days in the future') do |days|
  date = (Date.current + days.days).strftime('%Y-%m-%d')
  email = @current_user_email || 'member@link.cuhk.edu.hk'
  booking = Booking.joins(:user).where(users: { email: email }).where(start_time: Time.zone.parse("#{date} 00:00:00")..Time.zone.parse("#{date} 23:59:59")).first!
  visit edit_booking_path(booking, booking_date: date)
end

Then('I should see timetable date {string}') do |date|
  expect(page).to have_content("Selected date: #{date}")
end

Then('I should see timetable date for {int} days in the future') do |days|
  date = (Date.current + days.days).strftime('%Y-%m-%d')
  expect(page).to have_content("Selected date: #{date}")
end

Given('there is a booking for {string} by {string} from {int} days in the future at {string} to {int} days in the future at {string}') do |venue_name, user_email, start_days, start_time, end_days, end_time|
  venue = Venue.find_by!(name: venue_name)
  user = User.find_by!(email: user_email)
  start_date = (Date.current + start_days.days).strftime('%Y-%m-%d')
  end_date = (Date.current + end_days.days).strftime('%Y-%m-%d')

  create(
    :booking,
    venue: venue,
    user: user,
    start_time: Time.zone.parse("#{start_date} #{start_time}:00"),
    end_time: Time.zone.parse("#{end_date} #{end_time}:00")
  )
end

Then('the slot {string} should be marked unavailable') do |label|
  expect(page).to have_css('.timetable-slot.timetable-slot-unavailable', text: label)
end

Then('the slot {string} should be marked available') do |label|
  expect(page).to have_css('.timetable-slot.timetable-slot-available', text: label)
end

Then('the slot {string} should be marked selected') do |label|
  expect(page).to have_css('.timetable-slot.timetable-slot-selected', text: label)
end

Then('the slot {string} should not be marked selected') do |label|
  expect(page).not_to have_css('.timetable-slot.timetable-slot-selected', text: label)
end

Then('the {string} options should include:') do |field_label, table|
  field_id = field_label == 'Start time' ? 'booking_start_slot' : 'booking_end_slot'
  options = find("##{field_id}", visible: :all).all('option').map(&:text)
  table.raw.flatten.each do |expected_option|
    expect(options).to include(expected_option)
  end
end

Then('the {string} options should not include:') do |field_label, table|
  field_id = field_label == 'Start time' ? 'booking_start_slot' : 'booking_end_slot'
  options = find("##{field_id}", visible: :all).all('option').map(&:text)
  table.raw.flatten.each do |unexpected_option|
    expect(options).not_to include(unexpected_option)
  end
end

Then('the end time picker should be disabled') do
  expect(find('#booking_end_slot', visible: :all)).to be_disabled
end

Then('the end time picker should be enabled') do
  expect(find('#booking_end_slot', visible: :all)).not_to be_disabled
end
