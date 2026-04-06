class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("SENDGRID_FROM_EMAIL", "noreply@csci3100.tylerl.cyou")
  layout "mailer"
end
