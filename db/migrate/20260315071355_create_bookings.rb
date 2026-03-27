class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :equipment, null: false, foreign_key: true
      t.integer :quantity
      t.date :start_date
      t.date :end_date
      t.string :status

      t.timestamps
    end
  end
end
