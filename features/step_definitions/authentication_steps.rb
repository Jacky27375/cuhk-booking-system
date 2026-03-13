Given('the following users exist:') do |table|
  table.hashes.each do |hash|
    create(:user, email: hash['email'], password: hash['password'], role: hash['role'].to_sym)
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

Given('I am logged in as {string} with password {string}') do |email, password|
  visit login_path
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Log in'
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
