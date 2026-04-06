# SendGrid configuration for transactional email delivery.
# Uses the sendgrid-ruby gem's Web API client for direct API calls
# and ActionMailer SMTP relay for standard Rails email delivery.
#
# Required environment variable:
#   SENDGRID_API_KEY - Your SendGrid API key (starts with "SG.")
#
# Optional:
#   SENDGRID_FROM_EMAIL - Sender address (default: noreply@csci3100.tylerl.cyou)

if ENV["SENDGRID_API_KEY"].present?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: "smtp.sendgrid.net",
    port: 587,
    domain: ENV.fetch("APP_HOST", "csci3100.tylerl.cyou"),
    user_name: "apikey",
    password: ENV["SENDGRID_API_KEY"],
    authentication: :plain,
    enable_starttls_auto: true
  }
end
