Before('@equipment_booking') do
  tenant = Tenant.find_or_create_by!(slug: 'science-faculty') do |t|
    t.name = 'Science Faculty'
  end
  User.find_or_create_by!(email: 'student@link.cuhk.edu.hk') do |u|
    u.password = 'Password1!'
    u.password_confirmation = 'Password1!'
    u.role = :student
    u.tenant = tenant
  end
end

Given('the following equipment exists:') do |table|
  user = User.find_by!(email: 'student@link.cuhk.edu.hk')
  tenant = user.tenant
  table.hashes.each do |hash|
    Equipment.create!(
      name: hash['name'],
      quantity: hash['quantity'].to_i,
      tenant: tenant
    )
  end
end

When('I visit the equipment page') do
  visit equipments_path
end

When('I borrow {int} {string} from {string} to {string}') do |qty, name, start_date, end_date|
  equipment = Equipment.find_by!(name: name)
  visit borrow_form_equipment_path(equipment)
  fill_in 'Quantity', with: qty
  fill_in 'Start date', with: start_date
  fill_in 'End date', with: end_date
  click_button 'Borrow'
end

Then('the available count for {string} should show {int}') do |name, count|
  visit equipments_path
  expect(page).to have_content("#{count} available")
end

Given('I have an approved loan of {int} {string} ending today') do |qty, name|
  user = User.find_by!(email: 'student@link.cuhk.edu.hk')
  equipment = Equipment.find_by!(name: name)
  Booking.create!(
    equipment: equipment,
    user: user,
    quantity: qty,
    start_date: Date.current - 1.day,
    end_date: Date.current,
    status: :approved
  )
end

When('I mark the {string} as returned') do |name|
  equipment = Equipment.find_by!(name: name)
  visit my_bookings_path
  booking = Booking.find_by!(equipment: equipment)
  within("#booking_#{booking.id}") do
    click_button "Mark as Returned"
  end
end

Then('the available count for {string} should be restored') do |name|
  equipment = Equipment.find_by!(name: name)
  visit equipments_path
  expect(page).to have_content("#{equipment.quantity} available")
end

Then('my booking should show status {string}') do |status|
  visit my_bookings_path
  expect(page).to have_content(status)
end

When('I borrow {int} {string} from {int} days from now to {int} days from now') do |qty, name, start_days, end_days|
  equipment = Equipment.find_by!(name: name)
  visit borrow_form_equipment_path(equipment)
  fill_in 'Quantity', with: qty
  start_date = (Date.current + start_days.days).strftime('%Y-%m-%d')
  end_date = (Date.current + end_days.days).strftime('%Y-%m-%d')
  fill_in 'Start date', with: start_date
  fill_in 'End date', with: end_date
  click_button 'Borrow'
end

When('I attempt to borrow {int} {string} from {int} days from now to {int} days from now') do |qty, name, start_days, end_days|
  equipment = Equipment.find_by!(name: name)
  visit borrow_form_equipment_path(equipment)
  fill_in 'Quantity', with: qty
  start_date = (Date.current + start_days.days).strftime('%Y-%m-%d')
  end_date = (Date.current + end_days.days).strftime('%Y-%m-%d')
  fill_in 'Start date', with: start_date
  fill_in 'End date', with: end_date
  click_button 'Borrow'
end
