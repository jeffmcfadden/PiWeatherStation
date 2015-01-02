class Sensor < ActiveRecord::Base
  has_many :sensor_observations
  has_many :sensor_alarms

  enum sensor_type: [ :ds1820 ]

  serialize :sensor_settings, JSON

  def take_observation!
    previous_value = self.latest_value
    new_value = nil

    if self.ds1820?
      new_value = self.take_observation_ds1820!
    else
      Rails.logger.warn "I have no idea how to take an observation for a sensor of type #{self.sensor_type}"
    end

    if new_value.present?
      self.sensor_alarms.enabled.each do |sa|
        sa.sensor_value_changed( previous_value: previous_value, new_value: new_value )
      end
    end
  end

  def take_observation_ds1820!
    physical_sensor_device_id = self.sensor_settings["physical_sensor_device_id"] #Example: 28-00000202301d

    if Rails.env.production?
      output=`cat /sys/bus/w1/devices/#{physical_sensor_device_id}/w1_slave`
    else
      output = "bf 00 55 00 7f ff 0c 10 61 : crc=61 YES\nbf 00 55 00 7f ff 0c 10 61 t=11937"
    end
    cRaw = output.split( "\n" )[1].split( "t=" )[1].to_i
    temp_c = cRaw / 1000.0

    self.sensor_observations.create( { value: temp_c, observed_at: Time.now } )
    self.update_attributes( { latest_value: temp_c, latest_value_observed_at: Time.now } )

    temp_c
  end
end
