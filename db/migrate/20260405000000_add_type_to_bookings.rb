class AddTypeToBookings < ActiveRecord::Migration[8.1]
  def up
    add_column :bookings, :type, :string unless column_exists?(:bookings, :type)
    add_index :bookings, :type unless index_exists?(:bookings, :type)

    execute <<~SQL.squish
      UPDATE bookings
      SET type = CASE
        WHEN equipment_id IS NOT NULL THEN 'EquipmentBooking'
        ELSE 'VenueBooking'
      END
      WHERE type IS NULL
    SQL
  end

  def down
    remove_index :bookings, :type if index_exists?(:bookings, :type)
    remove_column :bookings, :type if column_exists?(:bookings, :type)
  end
end
