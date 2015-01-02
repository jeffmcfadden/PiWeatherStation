class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.string :name
      t.integer :sensor_type
      t.float :latest_value
      t.datetime :latest_value_observed_at
      t.text :params

      t.timestamps null: false
    end
  end
end
