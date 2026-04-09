class CreateVenueRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :venue_requests do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :tenant, null: false, foreign_key: true
      t.string :venue_name, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.text :rejection_reason
      t.datetime :reviewed_at
      t.timestamps
    end
  end
end
