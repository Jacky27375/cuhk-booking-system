class AddCollegeScopeSlugToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :college_scope_slug, :string
    add_index :users, :college_scope_slug

    execute <<~SQL.squish
      UPDATE users
      SET college_scope_slug = tenants.slug
      FROM tenants
      WHERE users.tenant_id = tenants.id
        AND users.role = 1
        AND tenants.slug IS NOT NULL
    SQL
  end

  def down
    remove_index :users, :college_scope_slug
    remove_column :users, :college_scope_slug
  end
end
