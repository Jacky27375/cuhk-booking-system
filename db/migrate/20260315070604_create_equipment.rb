class CreateEquipment < ActiveRecord::Migration[8.1]
  def change
    create_table :equipment do |t|
      t.string :name, null: false
      t.integer :quantity, null: false, default: 0
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
