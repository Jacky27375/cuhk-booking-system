Given('{string} has submitted a venue request for {string}') do |email, venue_name|
  user = User.find_by!(email: email)
  VenueRequest.create!(
    requester: user,
    tenant: user.tenant,
    venue_name: venue_name,
    description: "Request for #{venue_name}",
    status: :pending
  )
end

When('I visit the venue requests page') do
  visit venue_requests_path
end

When('I visit the new venue request page') do
  visit new_venue_request_path
end

Then('a venue named {string} should exist for {string}') do |venue_name, college_name|
  tenant = Tenant.find_by!(name: college_name)
  venue = Venue.find_by!(name: venue_name)
  expect(venue.tenant).to eq(tenant)
end
