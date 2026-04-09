class RenameSocietyMemberRoleToStudent < ActiveRecord::Migration[8.1]
  # The role column stores integer values (0 = society_member, now called student).
  # No data migration is needed because the integer mapping is unchanged.
  # This migration documents the rename in the migration history.
  def change
    # No-op: integer enum value 0 remains 0, only the Ruby symbol changed.
  end
end
