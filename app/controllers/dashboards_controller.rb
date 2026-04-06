class DashboardsController < ApplicationController
  before_action :require_admin_or_staff, only: :approvals

  def show
  end

  def approvals
    @bookings = Booking.includes(:venue, :user).pending

    if current_user.staff?
      @bookings = @bookings.for_tenant(current_user.tenant)
    end

    @bookings = sort_approval_bookings(@bookings)
  end

  private

  def sort_approval_bookings(scope)
    allowed = {
      "venue" => "venues.name",
      "department" => "venues.department",
      "user" => "users.email",
      "date" => "bookings.start_time",
      "status" => "bookings.status"
    }

    @sort_column = params[:sort]
    @sort_direction = params[:direction]

    unless allowed.key?(@sort_column) && %w[asc desc].include?(@sort_direction)
      @sort_column = nil
      @sort_direction = nil
      return scope.order(start_time: :desc)
    end

    scope.left_joins(:venue, :user).order(Arel.sql("#{allowed[@sort_column]} #{@sort_direction}"))
  end
end
