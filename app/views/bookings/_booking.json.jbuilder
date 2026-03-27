json.extract! booking, :id, :venue_id, :user_id, :start_time, :end_time, :created_at, :updated_at
json.url booking_url(booking, format: :json)
