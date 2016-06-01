class CreateApplications < ActiveRecord::Migration[5.0]
  def change
    create_table :applications do |t|
      t.string :app_id, index: true, null: false
      t.string :name, null: false
      t.integer :app_type, null: false
      t.timestamps
    end
  end
end
