class AddDepartmentToVenues < ActiveRecord::Migration[8.1]
  def change
    add_column :venues, :department, :string
  end
end
