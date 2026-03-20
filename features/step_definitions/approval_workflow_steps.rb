Given("the following venues exist:") do |table|
  table.hashes.each do |hash|
    create(:venue, name: hash["name"], department: hash["department"])
  end
end

Given("{string} has a pending booking for {string} on {string}") do |email, venue_name, date|
  user = User.find_by!(email: email)
  venue = Venue.find_by!(name: venue_name)
  start_time = Time.zone.parse("#{date} 10:00")
  end_time = Time.zone.parse("#{date} 12:00")

  create(
    :booking,
    user: user,
    venue: venue,
    start_time: start_time,
    end_time: end_time,
    status: :pending
  )
end

When("I visit the approval dashboard") do
  visit approval_dashboard_path
end

Then("I should see the pending booking for {string}") do |venue_name|
  expect(page).to have_content(venue_name)
end

Then("I should see status {string}") do |status|
  expect(page).to have_content(status)
end

When("I approve the booking for {string} on {string}") do |venue_name, date|
  visit approval_dashboard_path

  booking = Booking.joins(:venue)
                   .where(venues: { name: venue_name })
                   .where(start_time: Time.zone.parse(date).all_day)
                   .first
  @current_booking = booking

  within("##{ActionView::RecordIdentifier.dom_id(booking)}") do
    click_button "Approve"
  end
end

Then("the booking status should be {string}") do |status|
  booking = @current_booking || Booking.last
  expect(booking.reload.status).to eq(status.downcase)
end

Then("{string} should receive a confirmation email") do |email|
  mail = ActionMailer::Base.deliveries.select { |m| m.subject == "Booking Approved" }.last
  expect(mail).not_to be_nil
  expect(mail.to).to include(email)
  expect(mail.subject).to eq("Booking Approved")
end

When("I reject the booking for {string} on {string} with reason {string}") do |venue_name, date, reason|
  visit approval_dashboard_path

  booking = Booking.joins(:venue)
                   .where(venues: { name: venue_name })
                   .where(start_time: Time.zone.parse(date).all_day)
                   .first
  @current_booking = booking

  within("##{ActionView::RecordIdentifier.dom_id(booking)}") do
    fill_in "Reason", with: reason
    click_button "Reject"
  end
end

Then("{string} should receive a rejection email with {string}") do |email, reason|
  mail = ActionMailer::Base.deliveries.select { |m| m.subject == "Booking Rejected" }.last
  expect(mail).not_to be_nil
  expect(mail.to).to include(email)
  expect(mail.subject).to eq("Booking Rejected")
  expect(mail.body.encoded).to include(reason)
end

Given("there is a pending booking for {string} which belongs to {string}") do |venue_name, department|
  venue = create(:venue, name: venue_name, department: department)
  user = User.find_by(role: :society_member) || create(:user)
  create(:booking, venue: venue, user: user, status: :pending)
end

Given("I am viewing {string}") do |page_name|
  case page_name
  when "My Bookings"
    visit my_bookings_path
  else
    raise "Unknown page: #{page_name}"
  end
end

When("the staff approves my booking for {string}") do |venue_name|
  booking = Booking.joins(:venue)
                   .where(venues: { name: venue_name })
                   .first
  @current_booking = booking

  Capybara.using_session("staff_session") do
    visit login_path
    fill_in "Email", with: "staff@link.cuhk.edu.hk"
    fill_in "Password", with: "password1"
    click_button "Log in"

    visit approval_dashboard_path
    within("##{ActionView::RecordIdentifier.dom_id(booking)}") do
      click_button "Approve"
    end
  end
end

Then("I should see the status update to {string} without refreshing the page") do |status|
  booking = @current_booking || Booking.last
  expect(page).to have_css("[data-booking-id='#{booking.id}']", text: status)
end

Then("I should not be on the approval dashboard page") do
  expect(current_path).not_to eq(approval_dashboard_path)
end

Then("I should not see the booking for {string}") do |venue_name|
  expect(page).not_to have_content(venue_name)
end
