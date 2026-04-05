module BookingsHelper
	def booking_planner_frame_id
		"booking_planner"
	end

	def booking_date_filter_url(booking)
		booking.persisted? ? edit_booking_path(booking) : new_booking_path
	end

	def booking_form_url(booking)
		booking.persisted? ? booking_path(booking) : confirm_bookings_path
	end

	def booking_form_method(booking)
		booking.persisted? ? :patch : :post
	end

	def booking_submit_label(booking)
		booking.persisted? ? "Update Booking" : "Review Booking"
	end

	def booking_timetable_cell_class(slot)
		case slot[:css_class]
		when "timetable-slot-selected"
			"TimeTableCell_Selected"
		when "timetable-slot-unavailable"
			"TimeTableCell_Full"
		else
			"TimeTableCell_Available"
		end
	end

	def booking_timetable_slot_class(slot)
		["timetable-slot", slot[:css_class]].join(" ")
	end
end
