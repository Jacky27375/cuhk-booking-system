class AddTenantToVenues < ActiveRecord::Migration[8.1]
  def up
    add_reference :venues, :tenant, foreign_key: true

    execute <<~SQL.squish
      UPDATE venues
      SET tenant_id = tenants.id
      FROM tenants
      WHERE venues.department = tenants.name
    SQL
  end

  def down
    remove_reference :venues, :tenant, foreign_key: true
  end
end
