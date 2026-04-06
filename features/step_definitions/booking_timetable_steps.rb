When('I open the booking page for {string} on {string}') do |venue_name, date|
  venue = Venue.find_by!(name: venue_name)
  visit new_booking_path(venue_id: venue.id, booking_date: date)
end

When('I open the edit booking page for my booking on {string}') do |date|
  booking = Booking.joins(:user).where(users: { email: 'member@link.cuhk.edu.hk' }).where(start_time: Time.zone.parse("#{date} 00:00:00")..Time.zone.parse("#{date} 23:59:59")).first!
  visit edit_booking_path(booking, booking_date: date)
end

Then('I should see timetable date {string}') do |date|
  expect(page).to have_content("Selected date: #{date}")
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
