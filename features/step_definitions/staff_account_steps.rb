Given('the following college tenants exist:') do |table|
  table.hashes.each do |hash|
    Tenant.find_or_create_by!(name: hash['name']) do |t|
      t.slug = hash['name'].parameterize
      t.description = "#{hash['name']} facilities"
    end
  end
end

Given('a root staff account {string} exists for {string}') do |email, college_name|
  tenant = Tenant.find_by!(name: college_name)
  User.find_or_create_by!(email: email) do |u|
    u.password = 'Password1!'
    u.password_confirmation = 'Password1!'
    u.role = :staff
    u.is_root_account = true
    u.tenant = tenant
  end
end

Given('a regular staff {string} exists for {string}') do |email, college_name|
  tenant = Tenant.find_by!(name: college_name)
  User.find_or_create_by!(email: email) do |u|
    u.password = 'Password1!'
    u.password_confirmation = 'Password1!'
    u.role = :staff
    u.is_root_account = false
    u.tenant = tenant
  end
end

Given('a student {string} exists for {string}') do |email, college_name|
  tenant = Tenant.find_by!(name: college_name)
  User.find_or_create_by!(email: email) do |u|
    u.password = 'Password1!'
    u.password_confirmation = 'Password1!'
    u.role = :student
    u.tenant = tenant
  end
end

When('I visit the staff accounts page') do
  visit staff_accounts_path
end

When('I visit the new staff account page') do
  visit new_staff_account_path
end

Then('{string} should be a staff member of {string}') do |email, college_name|
  user = User.find_by!(email: email)
  tenant = Tenant.find_by!(name: college_name)
  expect(user.staff?).to be(true)
  expect(user.tenant).to eq(tenant)
end
