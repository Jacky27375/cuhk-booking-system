class SignupVerificationMailer < ApplicationMailer
  def verification_code
    @email = params.fetch(:email)
    @code = params.fetch(:code)

    mail to: @email, subject: "Your CUHK signup verification code"
  end
end
