class DashboardsController < ApplicationController
  before_action :require_admin_or_staff, only: :approvals

  def show
  end

  def approvals
    @bookings = Booking.includes(:venue, :user).pending

    if current_user.staff?
      if current_user_department.present?
        @bookings = @bookings.joins(:venue).where(venues: { department: current_user_department })
      else
        @bookings = Booking.none
      end
    end
  end
end
