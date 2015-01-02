class CreateSensorAlarmActions < ActiveRecord::Migration
  def change
    create_table :sensor_alarm_actions do |t|
      t.references :sensor_alarm, index: true
      t.integer :action_type
      t.text :params

      t.timestamps null: false
    end
    add_foreign_key :sensor_alarm_actions, :sensor_alarms
  end
end
