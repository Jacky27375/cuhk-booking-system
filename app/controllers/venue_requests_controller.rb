class VenueRequestsController < ApplicationController
  before_action :require_admin_or_staff
  before_action :require_admin, only: [:approve, :reject]
  before_action :set_venue_request, only: [:approve, :reject]

  def index
    @venue_requests = if current_user.admin?
      VenueRequest.includes(:requester, :tenant, :reviewed_by).order(created_at: :desc)
    else
      VenueRequest.where(requester: current_user).includes(:tenant, :reviewed_by).order(created_at: :desc)
    end
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
    @venue_request.approve!(current_user)
    redirect_to venue_requests_path, notice: "Venue request approved. Venue has been created."
  end

  def reject
    reason = params[:rejection_reason].to_s.strip
    @venue_request.reject!(current_user, reason: reason)
    redirect_to venue_requests_path, notice: "Venue request rejected."
  end

  private

  def set_venue_request
    @venue_request = VenueRequest.find(params[:id])
  end

  def venue_request_params
    params.require(:venue_request).permit(:venue_name, :description)
  end
end
