class AddEquipmentBookingFieldsToBookings < ActiveRecord::Migration[8.1]
  def change
    add_reference :bookings, :equipment, null: true, foreign_key: true
    add_column :bookings, :quantity, :integer
    add_column :bookings, :start_date, :date
    add_column :bookings, :end_date, :date
    change_column_null :bookings, :venue_id, true
  end
end
