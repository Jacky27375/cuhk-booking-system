class BookingsController < ApplicationController
  TIMETABLE_START_HOUR = 8
  TIMETABLE_END_HOUR = 22

  before_action :set_booking, only: %i[ show edit update destroy approve reject mark_returned ]
  before_action :require_admin_or_staff, only: %i[ index approve reject ]

  # GET /bookings or /bookings.json
  def index
    @bookings = booking_scope.order(start_time: :desc)
  end

  # GET /bookings/my
  def my
    @bookings = current_user.bookings.includes(:venue, :equipment).order(created_at: :desc)
  end

  # GET /bookings/1 or /bookings/1.json
  def show
  end

  # GET /bookings/new
  def new
    @booking = VenueBooking.new
    @venues = accessible_venues.order(:name)
    if params[:venue_id].present? && venue_accessible?(params[:venue_id])
      @booking.venue_id = params[:venue_id]
    end

    selected_date = booking_date_param
    start_slot = params.dig(:booking, :start_slot)
    end_slot = params.dig(:booking, :end_slot)
    if selected_date.present? && start_slot.present?
      @booking.start_time = combine_date_and_slot(selected_date, start_slot)
    end
    if selected_date.present? && end_slot.present?
      @booking.end_time = combine_date_and_slot(selected_date, end_slot)
    end

    prepare_timetable_context
  end

  # GET /bookings/1/edit
  def edit
    @venues = accessible_venues.order(:name)
    prepare_timetable_context
  end

  # POST /bookings/confirm
  def confirm
    @booking = VenueBooking.new(extracted_booking_attributes)
    @booking.user = current_user
    @venues = accessible_venues.order(:name)

    unless venue_accessible?(@booking.venue_id)
      @booking.errors.add(:venue, "is not accessible for your account")
      prepare_timetable_context
      render :new, status: :unprocessable_entity
      return
    end

    prepare_timetable_context
    if @booking.valid?
      render :confirm
    else
      render :new, status: :unprocessable_entity
    end
  end

  # POST /bookings or /bookings.json
  def create
    @booking = VenueBooking.new(extracted_booking_attributes)
    @booking.user = current_user
    @venues = accessible_venues.order(:name)

    unless venue_accessible?(@booking.venue_id)
      @booking.errors.add(:venue, "is not accessible for your account")
      prepare_timetable_context
      render :new, status: :unprocessable_entity
      return
    end

    respond_to do |format|
      if @booking.save
        format.html { redirect_to @booking, notice: "Booking was successfully created." }
        format.json { render :show, status: :created, location: @booking }
      else
        prepare_timetable_context
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookings/1 or /bookings/1.json
  def update
    @venues = accessible_venues.order(:name)
    attrs = extracted_booking_attributes
    requested_venue_id = attrs[:venue_id].presence || @booking.venue_id
    unless venue_accessible?(requested_venue_id)
      @booking.errors.add(:venue, "is not accessible for your account")
      prepare_timetable_context
      render :edit, status: :unprocessable_entity
      return
    end

    respond_to do |format|
      if @booking.update(attrs)
        format.html { redirect_to @booking, notice: "Booking was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @booking }
      else
        prepare_timetable_context
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def approve
    @booking.approve!
    send_booking_notification(:approved)

    redirect_to approval_dashboard_path, notice: "Booking approved."
  end

  def reject
    reason = params[:rejection_reason].to_s.strip
    @booking.reject!(reason)
    send_booking_notification(:rejected, reason: reason)

    redirect_to approval_dashboard_path, notice: "Booking rejected."
  end

  def mark_returned
    @booking.update!(status: :returned)
    redirect_to my_bookings_path, notice: "Equipment returned successfully."
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

    def extracted_booking_attributes
      attrs = booking_params.to_h.symbolize_keys
      date_value = booking_date_param
      start_slot = params.dig(:booking, :start_slot)
      end_slot = params.dig(:booking, :end_slot)

      if date_value.present? && start_slot.present?
        attrs[:start_time] = combine_date_and_slot(date_value, start_slot)
      end

      if date_value.present? && end_slot.present?
        attrs[:end_time] = combine_date_and_slot(date_value, end_slot)
      end

      attrs
    end

    def booking_date_param
      params.dig(:booking, :booking_date).presence || params[:booking_date].presence
    end

    def combine_date_and_slot(date_value, slot)
      Time.zone.parse("#{date_value} #{slot}")
    rescue ArgumentError
      nil
    end

    def booking_scope
      if current_user.admin?
        Booking.includes(:venue, :equipment, :user)
      elsif current_user.staff?
        Booking.for_tenant(current_user.tenant).includes(:venue, :equipment, :user)
      else
        current_user.bookings.includes(:venue, :equipment, :user)
      end
    end

    def accessible_venues
      Venue.visible_to_user(current_user)
    end

    def venue_accessible?(venue_id)
      accessible_venues.exists?(id: venue_id)
    end

    def send_booking_notification(action, reason: nil)
      sent = if action == :approved
        SendgridEmailService.send_booking_approved(@booking)
      elsif action == :rejected
        SendgridEmailService.send_booking_rejected(@booking, reason: reason)
      end

      # Fall back to ActionMailer when SendGrid is not configured or fails
      send_via_action_mailer(action, reason) unless sent
    rescue SendgridEmailService::DeliveryError => e
      Rails.logger.error("SendGrid delivery failed, falling back to ActionMailer: #{e.message}")
      send_via_action_mailer(action, reason)
    end

    def send_via_action_mailer(action, reason)
      if action == :approved
        BookingMailer.with(booking: @booking).approved.deliver_now
      else
        BookingMailer.with(booking: @booking, reason: reason).rejected.deliver_now
      end
    end

    def unauthorized_booking_redirect_path
      return approval_dashboard_path if action_name.in?(["approve", "reject"])

      current_user.admin? || current_user.staff? ? bookings_path : my_bookings_path
    end

    def prepare_timetable_context
      @booking_date = selected_booking_date
      @time_slot_options = build_time_slot_options
      @timetable_slots = build_timetable_slots
    end

    def selected_booking_date
      return Date.parse(booking_date_param) if booking_date_param.present?
      return @booking.start_time.to_date if @booking.start_time.present?

      Time.zone.today
    rescue ArgumentError
      Time.zone.today
    end

    def selected_venue_id
      @booking.venue_id.presence || params[:venue_id].presence
    end

    def day_bounds
      day_start = Time.zone.local(@booking_date.year, @booking_date.month, @booking_date.day, TIMETABLE_START_HOUR, 0, 0)
      day_end = Time.zone.local(@booking_date.year, @booking_date.month, @booking_date.day, TIMETABLE_END_HOUR, 0, 0)
      [day_start, day_end]
    end

    def bookings_for_selected_day
      return Booking.none unless selected_venue_id.present?

      day_start, day_end = day_bounds
      scope = Booking.where(venue_id: selected_venue_id)
                     .where("start_time < ? AND end_time > ?", day_end, day_start)
      if Booking.defined_enums.key?("status")
        rejected_status = Booking.statuses["rejected"]
        scope = scope.where.not(status: rejected_status) if rejected_status
      end
      scope
    end

    def selected_range
      return nil unless @booking.start_time.present? && @booking.end_time.present?
      return nil unless @booking.start_time.to_date == @booking_date

      [@booking.start_time, @booking.end_time]
    end

    def overlap?(slot_start, slot_end, range_start, range_end)
      slot_start < range_end && slot_end > range_start
    end

    def build_timetable_slots
      day_start, day_end = day_bounds
      existing_bookings = bookings_for_selected_day.to_a
      chosen_range = selected_range

      slots = []
      cursor = day_start
      while cursor < day_end
        slot_start = cursor
        slot_end = slot_start + 1.hour

        selected = chosen_range.present? && overlap?(slot_start, slot_end, chosen_range[0], chosen_range[1])
        unavailable = existing_bookings.any? do |booking|
          booking.id != @booking.id && overlap?(slot_start, slot_end, booking.start_time, booking.end_time)
        end

        css_class = if unavailable
                      "timetable-slot-unavailable"
        elsif selected
                "timetable-slot-selected"
        else
                      "timetable-slot-available"
        end

        slots << {
          label: "#{slot_start.strftime('%H:%M')} - #{slot_end.strftime('%H:%M')}",
          start_at: slot_start,
          end_at: slot_end,
          css_class: css_class
        }

        cursor = slot_end
      end

      slots
    end

    def build_time_slot_options
      options = []
      cursor = Time.zone.local(@booking_date.year, @booking_date.month, @booking_date.day, TIMETABLE_START_HOUR, 0, 0)
      day_end = Time.zone.local(@booking_date.year, @booking_date.month, @booking_date.day, TIMETABLE_END_HOUR, 0, 0)

      while cursor <= day_end
        options << cursor.strftime("%H:%M")
        cursor += 1.hour
      end

      options
    end
end
