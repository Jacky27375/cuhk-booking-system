Given('the following users exist:') do |table|
  table.hashes.each do |row|
    User.create!(
      email: row['email'],
      password: row['password'],
      role: row['role']
    )
  end
end

Given('I am on the login page') do
  visit login_path
end

Given('I am logged in as {string}') do |email|
  visit login_path
  fill_in 'Email', with: email
  fill_in 'Password', with: 'password1'
  click_button 'Log In'
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I click {string}') do |button_or_link|
  if page.has_button?(button_or_link)
    click_button button_or_link
  else
    click_link button_or_link
  end
end

When('I visit the staff dashboard') do
  visit staff_dashboard_path
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should be on the student dashboard') do
  expect(page).to have_current_path(dashboard_path)
  expect(page).to have_content('Student Dashboard')
end

Then('I should be on the login page') do
  expect(page).to have_current_path(login_path)
end

Then('I should be redirected to the student dashboard') do
  expect(page).to have_current_path(dashboard_path)
  expect(page).to have_content('Student Dashboard')
end
