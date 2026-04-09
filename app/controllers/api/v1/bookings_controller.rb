module Api
  module V1
    class BookingsController < BaseController
      def index
        bookings = scoped_bookings.order(created_at: :desc)
        bookings = bookings.where(status: params[:status]) if params[:status].present?
        bookings = bookings.where(type: "VenueBooking") if params[:type] == "venue"
        bookings = bookings.where(type: "EquipmentBooking") if params[:type] == "equipment"

        result = paginate(bookings)

        render json: {
          bookings: result[:records].includes(:venue, :equipment, :user).map { |b| booking_json(b) },
          meta: result[:meta]
        }
      end

      def show
        booking = scoped_bookings.find(params[:id])
        render json: { booking: booking_json(booking) }
      end

      def create
        unless current_api_user.student?
          render json: { error: "Forbidden", details: ["Only students can create bookings."] }, status: :forbidden
          return
        end

        booking = build_booking
        booking.save!

        render json: { booking: booking_json(booking) }, status: :created
      end

      private

      def scoped_bookings
        if current_api_user.admin?
          Booking.all
        elsif current_api_user.staff?
          Booking.for_tenant(current_api_user.tenant)
        else
          current_api_user.bookings
        end
      end

      def build_booking
        case params[:booking_type]
        when "venue"
          build_venue_booking
        when "equipment"
          build_equipment_booking
        else
          raise ActiveRecord::RecordInvalid.new(Booking.new.tap { |b|
            b.errors.add(:booking_type, "must be 'venue' or 'equipment'")
          })
        end
      end

      def build_venue_booking
        venue = Venue.find(params[:venue_id])
        VenueBooking.new(
          user: current_api_user,
          venue: venue,
          start_time: params[:start_time],
          end_time: params[:end_time]
        )
      end

      def build_equipment_booking
        equipment = Equipment.find(params[:equipment_id])
        EquipmentBooking.new(
          user: current_api_user,
          equipment: equipment,
          quantity: params[:quantity],
          start_date: params[:start_date],
          end_date: params[:end_date]
        )
      end

      def booking_json(booking)
        data = {
          id: booking.id,
          type: booking.type,
          status: booking.status,
          user_id: booking.user_id,
          user_email: booking.user.email,
          rejection_reason: booking.rejection_reason,
          created_at: booking.created_at.iso8601,
          updated_at: booking.updated_at.iso8601
        }

        if booking.is_a?(VenueBooking)
          data.merge!(
            venue_id: booking.venue_id,
            venue_name: booking.venue&.name,
            start_time: booking.start_time&.iso8601,
            end_time: booking.end_time&.iso8601
          )
        elsif booking.is_a?(EquipmentBooking)
          data.merge!(
            equipment_id: booking.equipment_id,
            equipment_name: booking.equipment&.name,
            quantity: booking.quantity,
            start_date: booking.start_date&.iso8601,
            end_date: booking.end_date&.iso8601
          )
        end

        data
      end
    end
  end
end
