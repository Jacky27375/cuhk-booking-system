Then("an email notification should be sent to {string}") do |email|
  deliveries = ActionMailer::Base.deliveries
  matching = deliveries.select { |m| m.to.include?(email) }
  expect(matching).not_to be_empty, "Expected an email to #{email} but none was found in #{deliveries.map(&:to)}"
end

Then("the email subject should contain {string}") do |subject_text|
  mail = ActionMailer::Base.deliveries.last
  expect(mail).not_to be_nil, "No emails were delivered"
  expect(mail.subject).to include(subject_text)
end

Then("the email body should include {string}") do |body_text|
  mail = ActionMailer::Base.deliveries.last
  expect(mail).not_to be_nil, "No emails were delivered"
  expect(mail.body.encoded).to include(body_text)
end
