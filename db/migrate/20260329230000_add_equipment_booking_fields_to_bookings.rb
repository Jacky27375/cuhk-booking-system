class AddEquipmentBookingFieldsToBookings < ActiveRecord::Migration[8.1]
  def change
    add_reference :bookings, :equipment, null: true unless column_exists?(:bookings, :equipment_id)
    add_index :bookings, :equipment_id unless index_exists?(:bookings, :equipment_id)
    add_foreign_key :bookings, :equipment, column: :equipment_id unless foreign_key_exists?(:bookings, :equipment, column: :equipment_id)

    add_column :bookings, :quantity, :integer unless column_exists?(:bookings, :quantity)
    add_column :bookings, :start_date, :date unless column_exists?(:bookings, :start_date)
    add_column :bookings, :end_date, :date unless column_exists?(:bookings, :end_date)

    change_column_null :bookings, :venue_id, true if column_exists?(:bookings, :venue_id)
  end
end
