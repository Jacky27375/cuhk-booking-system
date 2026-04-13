class AddActiveSessionTokenIssuedAtToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :active_session_token_issued_at, :datetime

    execute <<~SQL.squish
      UPDATE users
      SET active_session_token_issued_at = CURRENT_TIMESTAMP
      WHERE active_session_token IS NOT NULL
        AND active_session_token_issued_at IS NULL
    SQL
  end

  def down
    remove_column :users, :active_session_token_issued_at
  end
end
