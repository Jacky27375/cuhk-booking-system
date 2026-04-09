class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("RESEND_FROM_EMAIL", "noreply@csci3100.tylerl.cyou")
  layout "mailer"
end
