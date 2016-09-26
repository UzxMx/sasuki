class AddStatusRecordsToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :status_records, :string, default: '{}'
  end
end
