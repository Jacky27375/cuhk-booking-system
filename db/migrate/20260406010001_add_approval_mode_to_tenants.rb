class AddApprovalModeToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :approval_mode, :integer, null: false, default: 0
  end
end
