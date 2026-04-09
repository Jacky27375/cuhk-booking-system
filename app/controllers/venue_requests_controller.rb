class VenueRequestsController < ApplicationController
  STATUS_FILTERS = %w[pending approved rejected all].freeze

  before_action :require_admin_or_staff
  before_action :require_staff, only: [:new, :create]
  before_action :require_admin, only: [:approve, :reject]
  before_action :set_venue_request, only: [:approve, :reject]

  def index
    base_scope = if current_user.admin?
      VenueRequest.includes(:requester, :tenant, :reviewed_by)
    else
      VenueRequest.where(requester: current_user).includes(:tenant, :reviewed_by)
    end

    @status_filter = status_filter_param
    @venue_requests = filtered_scope(base_scope).order(request_order_clause)
    @status_counts = request_status_counts(base_scope) if current_user.admin?
  end

  def new
    @venue_request = VenueRequest.new
  end

  def create
    @venue_request = VenueRequest.new(venue_request_params)
    @venue_request.requester = current_user
    @venue_request.tenant = current_user.tenant

    if @venue_request.save
      redirect_to venue_requests_path, notice: "Venue request submitted successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  def approve
    unless @venue_request.pending?
      redirect_to venue_requests_path, alert: "Only pending requests can be approved."
      return
    end

    @venue_request.approve!(current_user)
    redirect_to venue_requests_path, notice: "Venue request approved for #{@venue_request.venue_name}. Venue has been created."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to venue_requests_path, alert: e.record.errors.full_messages.to_sentence.presence || "Venue request could not be approved."
  end

  def reject
    reason = params[:rejection_reason].to_s.strip
    if reason.blank?
      redirect_to venue_requests_path, alert: "Rejection reason cannot be blank."
      return
    end

    unless @venue_request.pending?
      redirect_to venue_requests_path, alert: "Only pending requests can be rejected."
      return
    end

    @venue_request.reject!(current_user, reason: reason)
    redirect_to venue_requests_path, notice: "Venue request rejected for #{@venue_request.venue_name}. Reason: #{reason}"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to venue_requests_path, alert: e.record.errors.full_messages.to_sentence.presence || "Venue request could not be rejected."
  end

  private

  def require_staff
    return if current_user&.staff?

    redirect_to venue_requests_path, alert: "Only staff can submit venue requests."
  end

  def set_venue_request
    @venue_request = VenueRequest.find(params[:id])
  end

  def venue_request_params
    params.require(:venue_request).permit(:venue_name, :description)
  end

  def status_filter_param
    requested = params[:status].to_s
    return "pending" if current_user.admin? && requested.blank?
    return "all" if requested.blank?

    STATUS_FILTERS.include?(requested) ? requested : "all"
  end

  def filtered_scope(scope)
    return scope if @status_filter == "all"

    scope.public_send(@status_filter)
  end

  def request_order_clause
    if current_user.admin? && @status_filter == "all"
      { status: :asc, created_at: :desc }
    else
      { created_at: :desc }
    end
  end

  def request_status_counts(scope)
    {
      "pending" => scope.pending.count,
      "approved" => scope.approved.count,
      "rejected" => scope.rejected.count,
      "all" => scope.count
    }
  end
end
