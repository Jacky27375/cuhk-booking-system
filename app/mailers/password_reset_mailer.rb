class PasswordResetMailer < ApplicationMailer
  def verification_code
    @email = params.fetch(:email)
    @code = params.fetch(:code)

    mail to: @email, subject: "Your CUHK password reset code"
  end
end
