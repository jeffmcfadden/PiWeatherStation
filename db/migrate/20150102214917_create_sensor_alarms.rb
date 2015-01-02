class CreateSensorAlarms < ActiveRecord::Migration
  def change
    create_table :sensor_alarms do |t|
      t.references :sensor, index: true
      t.float :value
      t.integer :direction
      t.boolean :enabled

      t.timestamps null: false
    end
    add_foreign_key :sensor_alarms, :sensors
  end
end
