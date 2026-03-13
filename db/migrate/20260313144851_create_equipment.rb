class CreateEquipment < ActiveRecord::Migration[8.1]
  def change
    create_table :equipment do |t|
      t.string :name
      t.string :department
      t.integer :quantity

      t.timestamps
    end
  end
end
