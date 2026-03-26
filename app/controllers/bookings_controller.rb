class BookingsController < ApplicationController
  before_action :set_booking, only: %i[ show edit update destroy approve reject ]
  before_action :require_admin_or_staff, only: %i[ index approve reject ]

  # GET /bookings or /bookings.json
  def index
    @bookings = booking_scope.order(start_time: :desc)
  end

  # GET /bookings/my
  def my
    @bookings = current_user.bookings.includes(:venue).order(start_time: :desc)
  end

  # GET /bookings/1 or /bookings/1.json
  def show
  end

  # GET /bookings/new
  def new
    @booking = Booking.new
    @venues = accessible_venues.order(:name)
    if params[:venue_id].present? && venue_accessible?(params[:venue_id])
      @booking.venue_id = params[:venue_id]
    end
  end

  # GET /bookings/1/edit
  def edit
    @venues = accessible_venues.order(:name)
  end

  # POST /bookings or /bookings.json
  def create
    @booking = Booking.new(booking_params)
    @booking.user = current_user
    @venues = accessible_venues.order(:name)

    unless venue_accessible?(@booking.venue_id)
      @booking.errors.add(:venue, "is not accessible for your account")
      render :new, status: :unprocessable_entity
      return
    end

    respond_to do |format|
      if @booking.save
        format.html { redirect_to @booking, notice: "Booking was successfully created." }
        format.json { render :show, status: :created, location: @booking }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookings/1 or /bookings/1.json
  def update
    @venues = accessible_venues.order(:name)
    requested_venue_id = booking_params[:venue_id].presence || @booking.venue_id
    unless venue_accessible?(requested_venue_id)
      @booking.errors.add(:venue, "is not accessible for your account")
      render :edit, status: :unprocessable_entity
      return
    end

    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to @booking, notice: "Booking was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def approve
    @booking.approve!
    BookingMailer.with(booking: @booking).approved.deliver_now

    redirect_to approval_dashboard_path, notice: "Booking approved."
  end

  def reject
    reason = params[:rejection_reason].to_s.strip
    @booking.reject!(reason)
    BookingMailer.with(booking: @booking, reason: reason).rejected.deliver_now

    redirect_to approval_dashboard_path, notice: "Booking rejected."
  end

  # DELETE /bookings/1 or /bookings/1.json
  def destroy
    @booking.destroy!

    respond_to do |format|
      format.html { redirect_to bookings_path, notice: "Booking was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = booking_scope.find(params.expect(:id))
    rescue ActiveRecord::RecordNotFound
      redirect_to unauthorized_booking_redirect_path, alert: "You are not authorized to access this booking."
    end

    # Only allow a list of trusted parameters through.
    def booking_params
      params.require(:booking).permit(:venue_id, :start_time, :end_time)
    end

    def booking_scope
      if current_user.admin?
        Booking.includes(:venue, :user)
      elsif current_user.staff?
        Booking.for_tenant(current_user.tenant).includes(:venue, :user)
      else
        current_user.bookings.includes(:venue, :user)
      end
    end

    def accessible_venues
      Venue.visible_to_user(current_user)
    end

    def venue_accessible?(venue_id)
      accessible_venues.exists?(id: venue_id)
    end

    def unauthorized_booking_redirect_path
      return approval_dashboard_path if action_name.in?(["approve", "reject"])

      current_user.admin? || current_user.staff? ? bookings_path : my_bookings_path
    end
end
