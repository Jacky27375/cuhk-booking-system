class BookingMailer < ApplicationMailer
  def approved
    @booking = params[:booking]
    mail(to: @booking.user.email, subject: "Booking Approved")
  end

  def rejected
    @booking = params[:booking]
    @reason = params[:reason].to_s
    mail(to: @booking.user.email, subject: "Booking Rejected")
  end
end
