class AddActiveSessionTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :active_session_token, :string
    add_index :users, :active_session_token, unique: true
  end
end
