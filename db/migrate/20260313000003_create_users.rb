class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, default: 0, null: false
      t.references :tenant, foreign_key: true
      t.references :society, foreign_key: true

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
