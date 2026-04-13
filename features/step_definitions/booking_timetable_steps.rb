When('I open the booking page for {string} on {string}') do |venue_name, date|
  venue = Venue.find_by!(name: venue_name)
  visit new_booking_path(venue_id: venue.id, booking_date: date)
  expect(page).to have_selector('#booking_start_slot', visible: :all)
end

When('I open the booking page for {string} on a date {int} days in the future') do |venue_name, days|
  venue = Venue.find_by!(name: venue_name)
  date = (Date.current + days.days).strftime('%Y-%m-%d')
  visit new_booking_path(venue_id: venue.id, booking_date: date)
  expect(page).to have_selector('#booking_start_slot', visible: :all)
end

When('I open the edit booking page for my booking on {string}') do |date|
  booking = Booking.joins(:user).where(users: { email: 'member@link.cuhk.edu.hk' }).where(start_time: Time.zone.parse("#{date} 00:00:00")..Time.zone.parse("#{date} 23:59:59")).first!
  visit edit_booking_path(booking, booking_date: date)
  expect(page).to have_selector('#booking_start_slot', visible: :all)
end

When('I open the edit booking page for my booking on a date {int} days in the future') do |days|
  date = (Date.current + days.days).strftime('%Y-%m-%d')
  email = @current_user_email || 'member@link.cuhk.edu.hk'
  booking = Booking.joins(:user).where(users: { email: email }).where(start_time: Time.zone.parse("#{date} 00:00:00")..Time.zone.parse("#{date} 23:59:59")).first!
  visit edit_booking_path(booking, booking_date: date)
  expect(page).to have_selector('#booking_start_slot', visible: :all)
end

Then('I should see timetable date {string}') do |date|
  expect(find('#booking_date', visible: :all).value).to eq(date)
end

Then('I should see timetable date for {int} days in the future') do |days|
  date = (Date.current + days.days).strftime('%Y-%m-%d')
  expect(find('#booking_date', visible: :all).value).to eq(date)
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
  row = find_timetable_row(label)
  expect(row).to have_css('.timetable-slot.timetable-slot-unavailable', text: 'Unavailable')
end

Then('the slot {string} should be marked available') do |label|
  row = find_timetable_row(label)
  expect(row).to have_css('.timetable-slot.timetable-slot-available', text: 'Available')
end

Then('the slot {string} should be marked selected') do |label|
  row = find_timetable_row(label)
  expect(row).to have_css('.timetable-slot.timetable-slot-selected', text: 'Selected')
end

Then('the slot {string} should not be marked selected') do |label|
  row = find_timetable_row(label)
  expect(row).not_to have_css('.timetable-slot.timetable-slot-selected')
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

def find_timetable_row(label)
  start_at, end_at = label.split(/\s*-\s*/, 2).map(&:strip)
  display_label = "#{Time.zone.parse(start_at).strftime('%I:%M %p')} - #{Time.zone.parse(end_at).strftime('%I:%M %p')}"
  find('table.TimeTable tbody tr', text: display_label)
end
