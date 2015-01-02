class CreateSensorObservations < ActiveRecord::Migration
  def change
    create_table :sensor_observations do |t|
      t.references :sensor, index: true
      t.float :value
      t.datetime :observed_at

      t.timestamps null: false
    end
    add_index :sensor_observations, :observed_at
    add_foreign_key :sensor_observations, :sensors
  end
end
