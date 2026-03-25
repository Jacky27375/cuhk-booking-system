class BookingsController < ApplicationController
  before_action :set_booking, only: %i[ show edit update destroy approve reject ]
  before_action :require_admin_or_staff, only: %i[ index approve reject ]

  # GET /bookings or /bookings.json
  def index
    @bookings = if current_user.admin?
                  Booking.includes(:venue, :user).order(start_time: :desc)
    else
                  Booking.for_tenant(current_user.tenant).includes(:venue, :user).order(start_time: :desc)
    end
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
    @booking.venue_id = params[:venue_id] if params[:venue_id]
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings or /bookings.json
  def create
    @booking = Booking.new(booking_params)
    @booking.user = current_user

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
    return unless authorize_staff_for_booking

    @booking.approve!
    BookingMailer.with(booking: @booking).approved.deliver_now

    redirect_to approval_dashboard_path, notice: "Booking approved."
  end

  def reject
    return unless authorize_staff_for_booking

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
      @booking = Booking.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def booking_params
      params.require(:booking).permit(:venue_id, :start_time, :end_time)
    end

    def authorize_staff_for_booking
      return true if current_user.admin?

      if @booking.venue.accessible_by_tenant?(current_user.tenant)
        true
      else
        redirect_to approval_dashboard_path, alert: "You are not authorized to manage this booking."
        false
      end
    end
end
