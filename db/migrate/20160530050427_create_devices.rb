class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.belongs_to :application, null: false
      t.string :device_id, null: false
      t.string :auth_token, null: false, default: ""
      t.string :username, null: false, default: ""
      t.boolean :online
      t.string :info, null: false, default: ""
      t.timestamps
    end
  end
end
