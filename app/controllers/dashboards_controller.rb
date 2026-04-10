class DashboardsController < ApplicationController
  before_action :require_admin_or_staff, only: :approvals

  def show
  end

  def approvals
    @bookings = Booking.awaiting_approval
                       .includes(:venue, :equipment, :user, approval_steps: :actor)

    @pending_venue_requests = if current_user.admin?
      VenueRequest.pending.includes(:requester, :tenant).order(created_at: :desc)
    else
      VenueRequest.none
    end

    if current_user.staff?
      scoped_ids = Booking.for_tenant(current_user.tenant).select(:id)
      @bookings = @bookings.where(id: scoped_ids)
    end

    @bookings = sort_approval_bookings(@bookings)
  end

  private

  def sort_approval_bookings(scope)
    allowed = %w[venue department user date status]

    @sort_column = params[:sort]
    @sort_direction = params[:direction]

    unless allowed.include?(@sort_column) && %w[asc desc].include?(@sort_direction)
      @sort_column = nil
      @sort_direction = nil
      return scope.order(start_time: :desc)
    end

    direction = @sort_direction == "asc" ? :asc : :desc
    bookings = Booking.arel_table
    venues = Venue.arel_table
    users = User.arel_table

    order_expr = case @sort_column
    when "venue"
      venues[:name]
    when "department"
      venues[:department]
    when "user"
      users[:email]
    when "date"
      bookings[:start_time]
    when "status"
      bookings[:status]
    end

    scope.left_joins(:venue, :user)
         .order(direction == :asc ? order_expr.asc : order_expr.desc)
  end
end
