Then('the venue department dropdown should include only:') do |table|
  expected_names = table.raw.flatten
  select_field = find('select#venue_department', visible: :all)
  option_names = select_field.all('option').map(&:text).reject(&:blank?)

  expect(option_names).to match_array(expected_names)
end

Then('the venue department dropdown should not include {string}') do |name|
  select_field = find('select#venue_department', visible: :all)
  option_names = select_field.all('option').map(&:text)

  expect(option_names).not_to include(name)
end

Then('the booking date input should have a minimum date {int} days in the future') do |days|
  expected_date = (Date.current + days.days).strftime('%Y-%m-%d')
  booking_date_input = find('input[name="booking_date"]', visible: :all)

  expect(booking_date_input[:min]).to eq(expected_date)
end

When('I visit the new equipment page') do
  visit new_equipment_path
end

When('I visit the new venue page') do
  visit new_venue_path
end

Then('the equipment tenant dropdown should include only:') do |table|
  expected_names = table.raw.flatten
  select_field = find('select#equipment_tenant_id', visible: :all)
  option_names = select_field.all('option').map(&:text).reject { |text| text == 'Select a tenant' }

  expect(option_names).to match_array(expected_names)
end
