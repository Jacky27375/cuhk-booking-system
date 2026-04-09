Given('the registration college tenants exist') do
  names = [
    'Chung Chi College',
    'New Asia College',
    'United College',
    'Shaw College',
    'Morningside College',
    'S.H. Ho College',
    'CW Chu College',
    'Wu Yee Sun College',
    'Lee Woo Sing College'
  ]

  names.each do |name|
    slug = name.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-|-$/, '')
    create(:tenant, name: name, slug: slug)
  end
end

When('I am on the registration page') do
  visit signup_path
end

Then('the college dropdown should include only:') do |table|
  expected_names = table.raw.flatten
  select_field = find('select#user_tenant_id')
  option_names = select_field.all('option').map(&:text).reject { |text| text == 'Select your college' }

  expect(option_names).to match_array(expected_names)
end

Then('the college dropdown should not include {string}') do |name|
  select_field = find('select#user_tenant_id')
  option_names = select_field.all('option').map(&:text)

  expect(option_names).not_to include(name)
end

When('I submit registration with tenant {string}') do |tenant_name|
  tenant = Tenant.find_by!(name: tenant_name)

  page.driver.post(
    signup_path,
    user: {
      email: 'blocked@link.cuhk.edu.hk',
      password: 'Password1!',
      password_confirmation: 'Password1!',
      tenant_id: tenant.id
    }
  )
end

Then('no user should exist with email {string}') do |email|
  expect(User.where(email: email)).to be_empty
end
