class DashboardsController < ApplicationController
  before_action :require_admin_or_staff, only: :approvals

  def show
  end

  def approvals
    @bookings = Booking.includes(:venue, :user).pending

    if current_user.staff?
      @bookings = @bookings.for_tenant(current_user.tenant)
    end
  end
end
