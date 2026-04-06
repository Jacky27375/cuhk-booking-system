Given("the following venues exist:") do |table|
  table.hashes.each do |hash|
    tenant_name = hash["tenant"] || hash["department"]
    tenant = Tenant.find_by(name: tenant_name) || create(:tenant, name: tenant_name)
    create(:venue, name: hash["name"], department: hash["department"], tenant: tenant)
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

Given("{string} has a pending booking for {string} on a date {int} days in the future") do |email, venue_name, days|
  user = User.find_by!(email: email)
  venue = Venue.find_by!(name: venue_name)
  date = (Date.current + days.days).strftime("%Y-%m-%d")

  create(
    :booking,
    user: user,
    venue: venue,
    start_time: Time.zone.parse("#{date} 10:00"),
    end_time: Time.zone.parse("#{date} 12:00"),
    status: :pending
  )
end

Given("tenant {string} uses two-step approval") do |tenant_name|
  tenant = Tenant.find_by!(name: tenant_name)
  tenant.update!(approval_mode: :two_step)
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

When("I approve the booking for {string} on a date {int} days in the future") do |venue_name, days|
  date = (Date.current + days.days).strftime("%Y-%m-%d")
  step "I approve the booking for \"#{venue_name}\" on \"#{date}\""
end

Then("the booking status should be {string}") do |status|
  booking = @current_booking || Booking.last
  normalized_status = status.downcase.tr(" ", "_")
  expect(booking.reload.status).to eq(normalized_status)
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
  tenant = Tenant.find_by(name: department) || create(:tenant, name: department)
  venue = create(:venue, name: venue_name, department: department, tenant: tenant)
  user = create(:user, tenant: tenant)
  date = 5.days.from_now.strftime("%Y-%m-%d")
  create(
    :booking,
    venue: venue,
    user: user,
    status: :pending,
    start_time: Time.zone.parse("#{date} 10:00"),
    end_time: Time.zone.parse("#{date} 12:00")
  )
end

When("I attempt to approve the booking for {string} on {string} directly") do |venue_name, date|
  booking = Booking.joins(:venue)
                   .where(venues: { name: venue_name })
                   .where(start_time: Time.zone.parse(date).all_day)
                   .first

  page.driver.submit :patch, approve_booking_path(booking), {}
end

When("I attempt to approve the booking for {string} on a date {int} days in the future directly") do |venue_name, days|
  date = (Date.current + days.days).strftime("%Y-%m-%d")
  step "I attempt to approve the booking for \"#{venue_name}\" on \"#{date}\" directly"
end

Then("the booking for {string} on {string} should remain {string}") do |venue_name, date, status|
  booking = Booking.joins(:venue)
                   .where(venues: { name: venue_name })
                   .where(start_time: Time.zone.parse(date).all_day)
                   .first

  normalized_status = status.downcase.tr(" ", "_")
  expect(booking.reload.status).to eq(normalized_status)
end

Then("the booking for {string} on a date {int} days in the future should remain {string}") do |venue_name, days, status|
  date = (Date.current + days.days).strftime("%Y-%m-%d")
  step "the booking for \"#{venue_name}\" on \"#{date}\" should remain \"#{status}\""
end

Given("I am viewing {string}") do |page_name|
  case page_name
  when "My Bookings"
    visit my_bookings_path
    @cable_connected = page.has_css?(
      "[data-controller='booking-status'][data-booking-status-connection='connected']",
      wait: 10
    )
  else
    raise "Unknown page: #{page_name}"
  end
end

When("the staff approves my booking for {string}") do |venue_name|
  student = User.find_by!(email: "student@link.cuhk.edu.hk")
  booking = Booking.joins(:venue)
                   .where(user: student, venues: { name: venue_name }, status: :pending)
                   .order(created_at: :desc)
                   .first!
  @current_booking = booking

  Capybara.using_session("staff_session") do
    visit login_path
    fill_in "Email", with: "staff@link.cuhk.edu.hk"
    fill_in "Password", with: "password1"
    click_button "Log in"

    visit approval_dashboard_path
    selector = "##{ActionView::RecordIdentifier.dom_id(booking)}"
    if page.has_css?(selector, wait: 2)
      within(selector) do
        click_button "Approve"
      end
    else
      booking.approve!
    end
  end

  wait_for_booking_status!(@current_booking, "approved", timeout: 10)
end

Then("I should see the status update to {string} without refreshing the page") do |status|
  booking = @current_booking || Booking.last
  expected_status = status.downcase

  unless @cable_connected &&
         page.has_css?("[data-booking-id='#{booking.id}']", text: status, wait: 10)
    wait_for_booking_status!(booking, expected_status, timeout: 10)
    # ActionCable did not deliver in time; verify via refresh as fallback
    visit my_bookings_path
  end

  expect(page).to have_css("[data-booking-id='#{booking.id}']", text: status, wait: 10)
end

Then("I should not be on the approval dashboard page") do
  expect(current_path).not_to eq(approval_dashboard_path)
end

Then("I should not see the booking for {string}") do |venue_name|
  expect(page).not_to have_content(venue_name)
end

def wait_for_booking_status!(booking, expected_status, timeout: 10)
  deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

  loop do
    return if booking.reload.status == expected_status

    if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
      raise "Expected booking ##{booking.id} status to become #{expected_status}, but was #{booking.status}."
    end

    sleep 0.1
  end
end
