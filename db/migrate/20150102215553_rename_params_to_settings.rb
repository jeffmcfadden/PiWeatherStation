class RenameParamsToSettings < ActiveRecord::Migration
  def change
    remove_column :sensors, :params

    add_column :sensors, :sensor_settings, :text

  end
end
