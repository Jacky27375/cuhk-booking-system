class AddStatusAndRejectionReasonToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :status, :integer, null: false, default: 0
    add_column :bookings, :rejection_reason, :text
  end
end
