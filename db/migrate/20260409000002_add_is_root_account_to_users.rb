class AddIsRootAccountToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :is_root_account, :boolean, default: false, null: false
  end
end
