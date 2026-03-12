class CreateSocieties < ActiveRecord::Migration[8.1]
  def change
    create_table :societies do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end
