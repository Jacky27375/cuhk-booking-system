class CreateApprovalSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :approval_steps do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :from_status, null: false
      t.string :to_status, null: false
      t.text :reason

      t.timestamps
    end

    add_index :approval_steps, [:booking_id, :created_at]
  end
end
